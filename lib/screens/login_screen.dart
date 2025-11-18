import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart' as ModelUser;
import 'profile_setup_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSignUpMode = false;
  bool _otpSent = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter an email before sending OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await AuthService.sendOtp(context, _emailController.text.trim());
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = await AuthService.signIn(
        context,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (userId != null) {
        // Check if profile is complete
        final user = await UserService.getProfile(userId);
        
        if (mounted) {
          if (user != null && user.isProfileComplete) {
            // Navigate to home screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            // Navigate to profile setup
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign-up handled via OTP flow (_sendOtp -> verifyOtp -> signUp)

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _errorMessage = '';
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo/Branding
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.work,
                          color: colorScheme.onPrimary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'GigFinder',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find your perfect opportunity',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUpMode ? 'Create Account' : 'Welcome Back',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          _isSignUpMode 
                            ? 'Create a new account to get started'
                            : 'Sign in to your account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: _isSignUpMode ? 'Create a password' : 'Enter your password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: colorScheme.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUpMode && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Error Message
                        if (_errorMessage.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Action Area
                        if (_isSignUpMode) ...[
                          if (!_otpSent) ...[
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      'Send OTP',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                          ] else ...[
                            // OTP input and final create button
                            TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Enter OTP'),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter the OTP sent to your email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = '';
                                  });
                                    try {
                                    final ok = await AuthService.verifyOtp(context, _emailController.text.trim(), _otpController.text.trim());
                                    if (ok) {
                                      // After OTP verification Supabase should set the current user.
                                      // Poll briefly for the auth user id (it may take a short moment).
                                      String? currentId;
                                      for (int i = 0; i < 10; i++) {
                                        currentId = AuthService.getCurrentUserId();
                                        if (currentId != null && currentId.isNotEmpty) break;
                                        await Future.delayed(const Duration(milliseconds: 300));
                                      }

                                      if (currentId == null || currentId.isEmpty) {
                                        setState(() { _errorMessage = 'Failed to determine authenticated user after OTP'; });
                                      } else {
                                        final user = ModelUser.User(
                                          id: currentId,
                                          email: _emailController.text.trim(),
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                        );
                                        final created = await UserService.createProfile(user);
                                        if (created) {
                                          if (!mounted) return;
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const ProfileSetupScreen()));
                                        } else {
                                          setState(() { _errorMessage = 'Sign up failed: could not create profile'; });
                                        }
                                      }
                                    } else {
                                      setState(() { _errorMessage = 'OTP verification failed'; });
                                    }
                                  } catch (e) {
                                    setState(() { _errorMessage = 'Error: ${e.toString()}'; });
                                  } finally {
                                    setState(() { _isLoading = false; });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      'Create Account',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ] else ...[
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor: colorScheme.primary.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                        
                        // Toggle sign up/sign in
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _isLoading ? null : _toggleMode,
                              child: Text(
                                _isSignUpMode 
                                  ? 'Already have an account? Sign In'
                                  : 'Don\'t have an account? Sign Up',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (!_isSignUpMode)
                              TextButton(
                                onPressed: _isLoading ? null : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                  );
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Footer
                Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}