import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

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
    await cred.user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
    return cred;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    _user = cred.user;
    notifyListeners();
    return cred;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      final cred = await _auth.signInWithPopup(googleProvider);
      _user = cred.user;
      notifyListeners();
      return cred;
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      _user = cred.user;
      notifyListeners();
      return cred;
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
}
