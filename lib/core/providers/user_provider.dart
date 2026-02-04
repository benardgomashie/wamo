import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  
  User? get currentUser => _currentUser;
  User? get user => _currentUser; // Add alias for compatibility
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await loadUserProfile(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserProfile(uid);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(_currentUser!.id, data);
      await loadUserProfile(_currentUser!.id);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
