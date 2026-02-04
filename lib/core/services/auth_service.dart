import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        if (verificationCompleted != null) {
          verificationCompleted(credential);
        } else {
          await signInWithCredential(credential);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        String errorMessage = 'Verification failed';
        
        if (e.code == 'invalid-phone-number') {
          errorMessage = 'Invalid phone number format';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many requests. Please try again later';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'Network error. Please check your connection';
        }
        
        verificationFailed(errorMessage);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        if (codeAutoRetrievalTimeout != null) {
          codeAutoRetrievalTimeout(verificationId);
        }
      },
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
    );
  }
  
  /// Verify OTP code
  Future<UserCredential?> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception('Verification ID is null. Please request OTP again.');
    }
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      return await signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw Exception('OTP expired. Please request a new code');
      }
      throw Exception('Verification failed: ${e.message}');
    }
  }
  
  /// Sign in with credential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }
  
  /// Check if user profile exists in Firestore
  Future<bool> userProfileExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }
  
  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    String? email,
    String role = 'creator',
  }) async {
    final user = app_user.User(
      id: uid,
      name: name,
      phone: phone,
      email: email,
      role: role,
      verificationStatus: 'pending',
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(uid).set(user.toMap());
  }
  
  /// Get user profile from Firestore
  Future<app_user.User?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    
    if (!doc.exists) {
      return null;
    }
    
    return app_user.User.fromMap(doc.data()!, doc.id);
  }
  
  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
  
  /// Update FCM token for notifications
  Future<void> updateFCMToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcm_token': token,
    });
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
    }
  }
  
  /// Resend OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
    );
  }
}
