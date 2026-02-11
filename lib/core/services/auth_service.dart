import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;
import '../utils/app_logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _logScope = 'AuthService';

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Verification ID for phone auth
  String? _verificationId;
  int? _resendToken;

  /// Send OTP to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    Function(PhoneAuthCredential credential)? verificationCompleted,
    Function(String verificationId)? codeAutoRetrievalTimeout,
  }) async {
    AppLogger.info(_logScope,
        'Phone verification start. phone=$phoneNumber resendToken=$_resendToken');

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        AppLogger.info(
            _logScope, 'Phone verification completed automatically.');
        // Auto-verification (Android only)
        if (verificationCompleted != null) {
          verificationCompleted(credential);
        } else {
          await signInWithCredential(credential);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        AppLogger.error(
          _logScope,
          'Phone verification failed. code=${e.code} message=${e.message}',
          e,
          e.stackTrace,
        );

        String errorMessage = 'Verification failed';

        if (e.code == 'invalid-phone-number') {
          errorMessage = 'Invalid phone number format';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many requests. Please try again later';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'Network error. Please check your connection';
        } else if (e.code == 'web-context-cancelled') {
          errorMessage = 'Verification cancelled. Please try again';
        } else {
          errorMessage = 'Verification failed: ${e.message}';
        }

        AppLogger.warn(
            _logScope, 'Phone verification user-facing error: $errorMessage');
        verificationFailed(errorMessage);
      },
      codeSent: (String verificationId, int? resendToken) {
        AppLogger.info(_logScope,
            'OTP code sent. verificationId=$verificationId resendToken=$resendToken');

        _verificationId = verificationId;
        _resendToken = resendToken;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        AppLogger.warn(_logScope,
            'OTP auto retrieval timeout. verificationId=$verificationId');

        _verificationId = verificationId;
        if (codeAutoRetrievalTimeout != null) {
          codeAutoRetrievalTimeout(verificationId);
        }
      },
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
    );
    AppLogger.info(_logScope, 'Phone verification request submitted.');
  }

  /// Verify OTP code
  Future<UserCredential?> verifyOTP(String otp,
      {String? verificationId}) async {
    AppLogger.info(_logScope, 'OTP verification start.');

    // Use passed verificationId or fall back to stored one
    final activeVerificationId = verificationId ?? _verificationId;
    AppLogger.info(_logScope, 'Using verificationId=$activeVerificationId');

    if (activeVerificationId == null) {
      AppLogger.error(_logScope, 'Verification ID is null.');
      throw Exception('Verification ID is null. Please request OTP again.');
    }

    try {
      AppLogger.info(_logScope, 'Creating phone auth credential.');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: activeVerificationId,
        smsCode: otp,
      );

      AppLogger.info(_logScope, 'Attempting sign-in with phone credential.');
      final result = await signInWithCredential(credential);
      AppLogger.info(_logScope, 'OTP verification successful.');
      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.error(
        _logScope,
        'OTP verification failed. code=${e.code} message=${e.message}',
        e,
        e.stackTrace,
      );

      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw Exception('OTP expired. Please request a new code');
      }
      throw Exception('Verification failed: ${e.message}');
    }
  }

  /// Sign in with credential
  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    AppLogger.info(_logScope, 'Signing in with phone credential.');
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      AppLogger.info(
        _logScope,
        'Sign-in successful. uid=${userCredential.user?.uid} phone=${userCredential.user?.phoneNumber}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error(
        _logScope,
        'Sign-in with credential failed. code=${e.code} message=${e.message}',
        e,
      );
      rethrow;
    }
  }

  /// Check if user profile exists in Firestore
  Future<bool> userProfileExists(String uid) async {
    AppLogger.info(_logScope, 'Checking profile existence. uid=$uid');
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      AppLogger.info(
          _logScope, 'Profile existence result. uid=$uid exists=${doc.exists}');
      return doc.exists;
    } catch (e, stackTrace) {
      AppLogger.error(_logScope,
          'Failed to check profile existence for uid=$uid', e, stackTrace);
      rethrow;
    }
  }

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String role = 'creator',
  }) async {
    AppLogger.info(_logScope, 'Creating user profile. uid=$uid role=$role');
    final user = app_user.User(
      id: uid,
      name: name,
      phone: phone,
      email: email,
      role: role,
      verificationStatus: 'pending',
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('users').doc(uid).set(user.toMap());
      AppLogger.info(_logScope, 'User profile created successfully. uid=$uid');
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed to create user profile for uid=$uid',
          e, stackTrace);
      rethrow;
    }
  }

  /// Get user profile from Firestore
  Future<app_user.User?> getUserProfile(String uid) async {
    AppLogger.info(_logScope, 'Fetching user profile. uid=$uid');
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        AppLogger.warn(_logScope, 'User profile not found. uid=$uid');
        return null;
      }

      AppLogger.info(_logScope, 'User profile fetched. uid=$uid');
      return app_user.User.fromMap(doc.data()!, doc.id);
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed to fetch user profile for uid=$uid', e,
          stackTrace);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    AppLogger.info(_logScope,
        'Updating user profile. uid=$uid fields=${data.keys.toList()}');
    try {
      await _firestore.collection('users').doc(uid).update(data);
      AppLogger.info(_logScope, 'User profile updated successfully. uid=$uid');
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed to update user profile for uid=$uid',
          e, stackTrace);
      rethrow;
    }
  }

  /// Update FCM token for notifications
  Future<void> updateFCMToken(String uid, String token) async {
    AppLogger.info(_logScope, 'Updating FCM token. uid=$uid');
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcm_token': token,
      });
      AppLogger.info(_logScope, 'FCM token updated. uid=$uid');
    } catch (e, stackTrace) {
      AppLogger.error(
          _logScope, 'Failed to update FCM token for uid=$uid', e, stackTrace);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    AppLogger.info(_logScope, 'Signing out current user.');
    try {
      await _auth.signOut();
      AppLogger.info(_logScope, 'Sign out successful.');
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Failed to sign out user.', e, stackTrace);
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      AppLogger.warn(_logScope, 'Deleting account for uid=${user.uid}');
      // Delete user data from Firestore
      try {
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();
        AppLogger.info(_logScope, 'Account deleted. uid=${user.uid}');
      } catch (e, stackTrace) {
        AppLogger.error(_logScope,
            'Failed deleting account for uid=${user.uid}', e, stackTrace);
        rethrow;
      }
    } else {
      AppLogger.warn(
          _logScope, 'Delete account called with no signed-in user.');
    }
  }

  /// Resend OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    AppLogger.info(_logScope, 'Resending OTP. phone=$phoneNumber');
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
    );
  }
}
