import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_logger.dart';
import 'widgets/phone_input_widget.dart';
import 'otp_verification_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  static const String _logScope = 'PhoneAuthScreen';

  bool _isLoading = false;
  String? _errorMessage;
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    AppLogger.info(
        _logScope, 'Send OTP tapped. rawInput=${_phoneController.text}');
    AppLogger.info(_logScope, 'Resolved phone number=$_fullPhoneNumber');

    if (_phoneController.text.isEmpty) {
      AppLogger.warn(_logScope, 'Validation failed: phone number empty.');
      setState(() {
        _errorMessage = 'Please enter your phone number';
      });
      return;
    }

    if (_phoneController.text.length < 9) {
      AppLogger.warn(
        _logScope,
        'Validation failed: phone number too short (${_phoneController.text.length} digits).',
      );
      setState(() {
        _errorMessage = 'Please enter a valid phone number';
      });
      return;
    }

    AppLogger.info(
        _logScope, 'Validation passed. Initiating phone verification.');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
        codeSent: (verificationId) {
          AppLogger.info(_logScope, 'OTP code sent callback received.');
          AppLogger.info(_logScope, 'Navigating to OTP screen.');
          setState(() {
            _isLoading = false;
          });

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: _fullPhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        verificationFailed: (error) {
          AppLogger.error(_logScope, 'Verification failed callback.', error);
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Exception while sending OTP.', e, stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.spacingXL),

                    // Logo or branding
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      ),
                      child: const Center(
                        child: Text(
                          'W',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXL),

                    // Title
                    const Text(
                      'Welcome to Wamo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingS),

                    const Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingXXL),

                    // Phone input
                    PhoneInputWidget(
                      controller: _phoneController,
                      errorText: _errorMessage,
                      onChanged: (fullNumber) {
                        setState(() {
                          _fullPhoneNumber = fullNumber;
                          _errorMessage = null;
                        });
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingXL),

                    // Send OTP button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Send Verification Code'),
                    ),

                    const SizedBox(height: AppTheme.spacingL),

                    // Privacy notice
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
