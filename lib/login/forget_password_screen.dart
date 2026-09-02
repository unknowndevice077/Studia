import 'package:app/login/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/theme/responsive.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please wait before trying again';
          break;
        default:
          errorMessage = 'An error occurred. Please try again later';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              // Cap the form width and center it so this screen doesn't
              // stretch full-bleed across tablet/desktop viewports.
              child: ResponsiveContent(
                maxWidth: 440,
                child: SizedBox(
                  height: size.height - MediaQuery.of(context).padding.top,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),

                      // ✅ Header
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      _emailSent
                                          ? context.colors.success
                                          : context.scheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  _emailSent
                                      ? Icons.mark_email_read
                                      : Icons.lock_reset,
                                  color: Colors.white,
                                  size: 28,
                                  semanticLabel:
                                      _emailSent
                                          ? 'Email Sent'
                                          : 'Reset Password',
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                _emailSent ? 'Email Sent!' : 'Reset Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: context.scheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _emailSent
                                    ? 'Check your email for reset instructions'
                                    : 'Enter your email to reset password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ✅ Form or Success Message
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_emailSent) ...[
                              // Error Message
                              if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: context.colors.danger.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.colors.danger.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: context.colors.danger,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),

                              // Email Form
                              Form(
                                key: _formKey,
                                child: _MinimalTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your email address';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value!)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Send Reset Email Button
                              _MinimalButton(
                                onPressed:
                                    _isLoading ? null : _sendPasswordResetEmail,
                                isLoading: _isLoading,
                                text: 'Send Reset Link',
                              ),

                              const SizedBox(height: 24),

                              // ✅ Forgot Email Section
                              Container(
                                padding: const EdgeInsets.all(
                                  16,
                                ), // Reduced from 20
                                decoration: BoxDecoration(
                                  color: context.scheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.scheme.outlineVariant,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      color: context.scheme.onSurfaceVariant,
                                      size: 24, // Reduced from 32
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ), // Reduced from 16
                                    Text(
                                      'Forgot your email?',
                                      style: TextStyle(
                                        fontSize: 16, // Reduced from 18
                                        fontWeight: FontWeight.w600,
                                        color: context.scheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6), // Reduced from 8
                                    Text(
                                      'Contact support to recover your account',
                                      style: TextStyle(
                                        fontSize: 13, // Reduced from 14
                                        color: context.scheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ), // Reduced from 16
                                    Container(
                                      height: 40, // Reduced from 44
                                      decoration: BoxDecoration(
                                        color: context.scheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: context.scheme.outlineVariant,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          // Updated email address
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      'Contact support at studia@gmail.com',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  context.scheme.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              margin: EdgeInsets.all(16),
                                              action: SnackBarAction(
                                                label: 'Copy',
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  // Optional: Copy email to clipboard
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: 'studia@gmail.com',
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Email copied to clipboard',
                                                      ),
                                                      duration: Duration(
                                                        seconds: 1,
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Contact Support',
                                          style: TextStyle(
                                            color:
                                                context.scheme.onSurfaceVariant,
                                            fontSize: 13, // Reduced from 14
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              // Success Message and Actions
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: context.colors.success.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.colors.success.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: context.colors.success,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Reset link sent successfully!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.success,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please check your email and follow the instructions to reset your password.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.colors.success,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Try Different Email
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _emailSent = false;
                                      _emailController.clear();
                                      _errorMessage = null;
                                    });
                                  },
                                  child: Text(
                                    'Try different email',
                                    style: TextStyle(
                                      color: context.scheme.onSurfaceVariant,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ✅ Help Text (only show when not email sent)
                      if (!_emailSent)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.scheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.scheme.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: context.scheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Make sure to check your spam folder if you don\'t see the email.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.scheme.primary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ✅ Back to Login Button (always visible at bottom)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: context.scheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.scheme.outlineVariant,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => Auth()),
                                (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: context.scheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Back to Sign In',
                                  style: TextStyle(
                                    color: context.scheme.onSurfaceVariant,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
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

// ✅ Reuse the same components from login screen
class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _MinimalTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // Use TextFormField's built-in errorBorder and errorText
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.scheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.danger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.danger, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

class _MinimalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const _MinimalButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color:
            onPressed != null
                ? context.scheme.primary
                : context.scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      ),
    );
  }
}
