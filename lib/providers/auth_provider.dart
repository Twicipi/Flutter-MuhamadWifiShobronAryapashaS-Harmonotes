import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser);
      } else {
        _setUnauthenticated();
      }
    });
  }

  Future<void> _loadUserData(User firebaseUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        _user = UserModel.fromMap(userDoc.data()!);
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
      _setUnauthenticated();
    }
  }

  void _setUnauthenticated() {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.error != null) {
      _setError(result.error!);
      return false;
    }

    if (result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.error != null) {
      _setError(result.error!);
      return false;
    }

    if (result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();

    final result = await _authService.signInWithGoogle();

    if (result.error != null) {
      _setError(result.error!);
      return false;
    }

    if (result.user == null && result.error == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    if (result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _setUnauthenticated();
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  Future<bool> resetPassword(String email) async {
    final error = await _authService.resetPassword(email);
    if (error != null) {
      _setError(error);
      return false;
    }
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}