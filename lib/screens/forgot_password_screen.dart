import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // OTP / new password controllers
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Send OTP (email-based) for password reset
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.sendOtp(context, email);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ok = await AuthService.verifyOtp(context, email, otp);
      if (!mounted) return;
      if (ok) {
        setState(() => _otpVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP verified — enter a new password')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP verification failed')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verification error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Set the new password (user should be authenticated after OTP verification)
  Future<void> _setNewPassword() async {
    final pw = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pw.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill both password fields')));
      return;
    }
    if (pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    if (pw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.updatePassword(context, pw);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated — please sign in')));

      // Return to the root (login) screen:
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _simpleEmailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    final v = value.trim();
    if (v.length < 5 || !v.contains('@') || !v.contains('.')) return 'Please enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Enter the email associated with your account. We will send an OTP to your inbox to reset the password.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email field (always visible)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: _simpleEmailValidator,
                  ),
                  const SizedBox(height: 12),

                  // If OTP not yet sent -> Send OTP button
                  if (!_otpSent)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          // run validator first
                          if (_formKey.currentState?.validate() ?? false) {
                            _sendOtp();
                          }
                        },
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Send OTP'),
                      ),
                    ),

                  // If OTP sent but not verified -> show OTP input + Verify button
                  if (_otpSent && !_otpVerified) ...[
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Enter OTP', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Verify OTP'),
                      ),
                    ),
                  ],

                  // If OTP verified -> show New Password / Confirm and Submit
                  if (_otpVerified) ...[
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _setNewPassword,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('Set Password'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}