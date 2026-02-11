import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_logger.dart';
import '../../app/routes.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final AuthService _authService = AuthService();
  static const String _logScope = 'OTPVerificationScreen';

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    // Store the initial verification ID
    _currentVerificationId = widget.verificationId;
    AppLogger.info(
      _logScope,
      'Screen initialized with verificationId=$_currentVerificationId',
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    AppLogger.info(_logScope, 'Verify OTP tapped. length=${_otp.length}');

    if (_otp.length != 6) {
      AppLogger.warn(_logScope, 'Validation failed: OTP incomplete.');
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code';
      });
      return;
    }

    AppLogger.info(
        _logScope, 'OTP validation passed. Verifying with Firebase.');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _authService.verifyOTP(_otp,
          verificationId: _currentVerificationId);

      if (userCredential != null && userCredential.user != null) {
        AppLogger.info(
            _logScope, 'Sign-in successful. uid=${userCredential.user!.uid}');
        AppLogger.info(_logScope, 'Navigating to ${AppRoutes.home}.');

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // Navigate to home and let AuthWrapper handle profile check
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'OTP verification failed.', e, stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _resendOTP() async {
    AppLogger.info(_logScope, 'Resend OTP tapped. phone=${widget.phoneNumber}');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resendOTP(
        phoneNumber: widget.phoneNumber,
        codeSent: (verificationId) {
          AppLogger.info(_logScope, 'New OTP sent successfully.');
          setState(() {
            _currentVerificationId = verificationId;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New code sent successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
        verificationFailed: (error) {
          AppLogger.error(_logScope, 'Resend OTP failed.', error);
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(_logScope, 'Resend OTP exception.', e, stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to resend code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
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

                    // Icon
                    const Icon(
                      Icons.sms_outlined,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),

                    const SizedBox(height: AppTheme.spacingXL),

                    // Title
                    const Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Description
                    Text(
                      'We sent a 6-digit code to\n${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacingXXL),

                    // OTP input boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                                borderSide: const BorderSide(
                                    color: AppTheme.dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                // Move to next field
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  // Last field, verify OTP
                                  _focusNodes[index].unfocus();
                                  _verifyOTP();
                                }
                              } else if (value.isEmpty && index > 0) {
                                // Move to previous field on backspace
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: AppTheme.spacingXL),

                    // Verify button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
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
                          : const Text('Verify Code'),
                    ),

                    const SizedBox(height: AppTheme.spacingM),

                    // Resend code
                    TextButton(
                      onPressed: _isLoading ? null : _resendOTP,
                      child: const Text('Resend Code'),
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
