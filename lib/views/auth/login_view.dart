/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: login_view.dart - Authentication Screen: Sign In / Sign Up
 *           Demonstrates: Form handling, validation, Provider state management
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_theme.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // Sign In
  final _signInKey  = GlobalKey<FormState>();
  final _siEmail    = TextEditingController();
  final _siPassword = TextEditingController();
  bool  _siObscure  = true;

  // Sign Up
  final _signUpKey  = GlobalKey<FormState>();
  final _suEmail    = TextEditingController();
  final _suPassword = TextEditingController();
  final _suConfirm  = TextEditingController();
  bool  _suObscure  = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _siEmail.dispose(); _siPassword.dispose();
    _suEmail.dispose(); _suPassword.dispose(); _suConfirm.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!_signInKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.signIn(_siEmail.text, _siPassword.text);
    if (!ok && mounted) _showSnack(auth.errorMessage ?? 'Sign in failed', isError: true);
  }

  Future<void> _signUp() async {
    if (!_signUpKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final ok = await auth.signUp(_suEmail.text, _suPassword.text);
    if (!mounted) return;
    if (ok) {
      _showSnack('Account created! Please verify your email then sign in.');
      _tabs.animateTo(0);
    } else {
      _showSnack(auth.errorMessage ?? 'Sign up failed', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(children: [
          // Header
          const SizedBox(height: 48),
          const Icon(Icons.school, color: Colors.white, size: 64),
          const SizedBox(height: 12),
          const Text(
            'Student Assistant\nApplication System',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('IT Department – CUT Free State',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 32),

          // Card area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(children: [
                // Tab bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textMuted,
                      dividerColor: Colors.transparent,
                      tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [_buildSignIn(), _buildSignUp()],
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Sign In Form ──────────────────────────────────────────────────────────
  Widget _buildSignIn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signInKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),

          // Email
          TextFormField(
            controller: _siEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v.trim()))
                return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _siPassword,
            obscureText: _siObscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signIn(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_siObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _siObscure = !_siObscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit
          Consumer<AuthViewModel>(
            builder: (_, auth, __) => ElevatedButton(
              onPressed: auth.isLoading ? null : _signIn,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Sign In'),
            ),
          ),

          // Forgot password
          TextButton(
            onPressed: () => _showResetDialog(),
            child: const Text('Forgot password?'),
          ),
        ]),
      ),
    );
  }

  // ── Sign Up Form ──────────────────────────────────────────────────────────
  Widget _buildSignUp() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signUpKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),

          TextFormField(
            controller: _suEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v.trim()))
                return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _suPassword,
            obscureText: _suObscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_suObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _suObscure = !_suObscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _suConfirm,
            obscureText: _suObscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signUp(),
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _suPassword.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),

          Consumer<AuthViewModel>(
            builder: (_, auth, __) => ElevatedButton(
              onPressed: auth.isLoading ? null : _signUp,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account'),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Password Reset Dialog ─────────────────────────────────────────────────
  void _showResetDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Your email address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<AuthViewModel>();
              final ok = await auth.sendPasswordReset(emailCtrl.text);
              if (mounted) {
                _showSnack(ok
                    ? 'Reset email sent! Check your inbox.'
                    : (auth.errorMessage ?? 'Failed to send reset email'),
                    isError: !ok);
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
