import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminAuthService extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  User? _user;
  bool _isAdmin = false;
  bool _loaded = false;

  AdminAuthService() {
    _auth.authStateChanges().listen((u) async {
      _user = u;
      if (u != null) {
        _isAdmin = await _checkAdmin(u.uid);
      } else {
        _isAdmin = false;
      }
      _loaded = true;
      notifyListeners();
    });
  }

  bool get ready => _loaded;
  User? get user => _user ?? _auth.currentUser;
  bool get isAuthenticated => user != null && _isAdmin;
  bool get isAdmin => _isAdmin;

  Future<bool> _checkAdmin(String uid) async {
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists && (doc.data()?['active'] != false);
  }

  Future<void> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    _user = cred.user;
    _isAdmin = await _checkAdmin(_user!.uid);
    if (!_isAdmin) {
      await _auth.signOut();
      _user = null;
      throw Exception('Not authorized as admin');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _isAdmin = false;
    notifyListeners();
  }
}
