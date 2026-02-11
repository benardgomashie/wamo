import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_logger.dart';
import '../../widgets/wamo_toast.dart';

class CreateProfileScreen extends StatefulWidget {
  final String uid;
  final String phoneNumber;

  const CreateProfileScreen({
    super.key,
    required this.uid,
    required this.phoneNumber,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  static const String _logScope = 'CreateProfileScreen';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    AppLogger.info(_logScope, 'Complete profile tapped. uid=${widget.uid}');
    if (!_formKey.currentState!.validate()) {
      AppLogger.warn(_logScope, 'Validation failed; profile not submitted.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.info(_logScope, 'Submitting profile to Firestore.');
      await _authService.createUserProfile(
        uid: widget.uid,
        name: _nameController.text.trim(),
        phone: widget.phoneNumber,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        role: 'creator',
      );

      if (!mounted) return;

      // Navigate to home
      AppLogger.info(
          _logScope, 'Profile saved; navigating to ${AppRoutes.home}.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!context.mounted) return;
      AppLogger.error(_logScope, 'Failed to create profile.', e);
      WamoToast.error(context, 'Error creating profile: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppTheme.spacingL),

                      // Icon
                      const Icon(
                        Icons.person_outline,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),

                      const SizedBox(height: AppTheme.spacingXL),

                      const Text(
                        'Tell us about yourself',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppTheme.spacingS),

                      const Text(
                        'This information helps us verify your campaigns',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppTheme.spacingXXL),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Email field (optional)
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (Optional)',
                          hintText: 'Enter your email address',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Phone display (read-only)
                      TextFormField(
                        initialValue: widget.phoneNumber,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          enabled: false,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingXXL),

                      // Create profile button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Complete Profile'),
                      ),

                      const SizedBox(height: AppTheme.spacingL),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Text(
                                'Your profile will be verified before you can create campaigns',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
