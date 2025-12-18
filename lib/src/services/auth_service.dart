import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final _db = FirebaseFirestore.instance;

  AuthService() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user ?? _auth.currentUser;
  bool get isAuthenticated => user != null;
  String? get displayName => user?.displayName ?? user?.email?.split('@').first;

  Future<UserCredential> registerWithEmail(String email, String password, {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null && displayName.isNotEmpty) {
      await cred.user?.updateDisplayName(displayName);
    }
    await _ensureLandlordDoc(cred.user, displayNameHint: displayName);
    await cred.user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
    return cred;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = cred.user;
      await _ensureLandlordDoc(_user);
      notifyListeners();
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(googleProvider);
        _user = cred.user;
        await _ensureLandlordDoc(_user);
        notifyListeners();
        return cred;
      } else {
        // Clear any existing sign-in attempts
        try {
          await GoogleSignIn().signOut();
        } catch (_) {
          // Ignore errors from sign out
        }

        // Use serverClientId from google-services.json (web client type 3)
        // This is the OAuth 2.0 client ID for web application
        GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: '34852440749-13q9rar185r16ipcfbpuknbv4eo017fa.apps.googleusercontent.com',
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception('Sign in aborted by user');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Check if we got the required tokens
        if (googleAuth.idToken == null) {
          throw Exception(
            'Failed to get Google authentication tokens.\n\n'
            'This usually means:\n'
            '1. SHA-1 fingerprint is missing in Firebase Console\n'
            '2. OAuth client is not configured\n\n'
            'To fix:\n'
            '1. Get your SHA-1: Run "keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android" (on Windows: check Android Studio > Gradle > signingReport)\n'
            '2. Go to Firebase Console > Project Settings > Your Android App\n'
            '3. Add SHA-1 fingerprint\n'
            '4. Download updated google-services.json and replace the current one'
          );
        }
        
        if (googleAuth.accessToken == null) {
          // Some configurations work with just idToken
          throw Exception('Failed to get Google access token. Please check your Firebase configuration.');
        }
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        final cred = await _auth.signInWithCredential(credential);
        _user = cred.user;
        await _ensureLandlordDoc(_user);
        notifyListeners();
        return cred;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _mapAuthError(e);
      if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.code.contains('10') || e.message?.contains('10') == true) {
        errorMessage = 'Google Sign-In configuration error. Please ensure:\n1. SHA-1 fingerprint is added to Firebase Console\n2. OAuth client ID is configured correctly\n3. google-services.json is up to date';
      }
      throw Exception(errorMessage);
    } on PlatformException catch (e) {
      String errorMessage = 'Google sign in failed';
      if (e.code == 'sign_in_failed' || e.message?.contains('10') == true) {
        errorMessage = 'Google Sign-In configuration error. Please ensure:\n1. SHA-1 fingerprint is added to Firebase Console\n2. OAuth client ID is configured correctly\n3. google-services.json is up to date';
      } else {
        errorMessage = 'Google sign in failed: ${e.message ?? e.toString()}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      String errorMessage = 'Google sign in failed: ${e.toString()}';
      if (e.toString().contains('10') || e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage = 'Google Sign-In configuration error. Please ensure:\n1. SHA-1 fingerprint is added to Firebase Console\n2. OAuth client ID is configured correctly\n3. google-services.json is up to date';
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut().catchError((_) {});
    }
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    
    if (user.email == null) throw Exception('User email not available');
    
    // Re-authenticate user with current password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    
    // Update password
    await user.updatePassword(newPassword);
    notifyListeners();
  }

  Future<void> changeDisplayName(String newDisplayName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    
    await user.updateDisplayName(newDisplayName);
    await user.reload();
    _user = _auth.currentUser;
    
    // Update in Firestore
    if (user.uid.isNotEmpty) {
      await _db.collection('landlords').doc(user.uid).set({
        'name': newDisplayName,
      }, SetOptions(merge: true));
    }
    
    notifyListeners();
  }

  Future<void> changeEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    
    if (user.email == null) throw Exception('Current email not available');
    
    // Re-authenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    
    // Update email
    await user.updateEmail(newEmail);
    await user.reload();
    _user = _auth.currentUser;
    
    // Update in Firestore
    if (user.uid.isNotEmpty) {
      await _db.collection('landlords').doc(user.uid).set({
        'email': newEmail,
      }, SetOptions(merge: true));
    }
    
    notifyListeners();
  }

  Future<void> _ensureLandlordDoc(User? user, {String? displayNameHint}) async {
    if (user == null) return;
    final ref = _db.collection('landlords').doc(user.uid);
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    final name = user.displayName ?? displayNameHint ?? user.email?.split('@').first;
    final photoUrl = user.photoURL; // Get photo URL from Firebase Auth (for Google sign-in)
    
    final dataToSet = <String, dynamic>{
      'name': name,
      'email': user.email,
      'lastLoginAt': now,
    };
    
    // If user has a photo URL from Google Auth and Firestore doesn't have one, save it
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Check if Firestore already has a photoUrl
      String? existingPhotoUrl;
      if (snap.exists) {
        existingPhotoUrl = snap.data()?['photoUrl'] as String?;
      }
      // Only update if Firestore doesn't have one or if it's different from Auth
      if (existingPhotoUrl == null || existingPhotoUrl != photoUrl) {
        dataToSet['photoUrl'] = photoUrl;
      }
    }
    
    if (!snap.exists) {
      dataToSet['active'] = true;
      dataToSet['createdAt'] = now;
      await ref.set(dataToSet, SetOptions(merge: true));
    } else {
      await ref.set(dataToSet, SetOptions(merge: true));
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password';
      case 'user-not-found':
        return 'No account found for that email';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'invalid-email':
        return 'The email address is not valid';
      default:
        return 'Authentication failed: ${e.code}';
    }
  }
}
