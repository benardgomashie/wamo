import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/app_logger.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  static const String _logScope = 'UserProvider';

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
        AppLogger.info(_logScope,
            'Auth listener: user signed in. uid=${firebaseUser.uid}');
        await loadUserProfile(firebaseUser.uid);
      } else {
        AppLogger.info(_logScope, 'Auth listener: user signed out.');
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUserProfile(String uid) async {
    AppLogger.info(_logScope, 'Loading user profile. uid=$uid');
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserProfile(uid);
      AppLogger.info(
          _logScope, 'User profile loaded. found=${_currentUser != null}');
    } catch (e) {
      AppLogger.error(_logScope, 'Error loading user profile for uid=$uid', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    AppLogger.info(_logScope, 'Updating profile for uid=${_currentUser!.id}');

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(_currentUser!.id, data);
      await loadUserProfile(_currentUser!.id);
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error updating profile for uid=${_currentUser!.id}', e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    AppLogger.info(_logScope, 'Signing out via provider.');
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
