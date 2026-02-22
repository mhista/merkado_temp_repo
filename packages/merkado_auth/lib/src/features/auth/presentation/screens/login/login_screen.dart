import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_auth/src/features/auth/presentation/cubit/auth_cubit.dart';
import '../password/forgot_password_screen.dart';
import '../signup/signup_screen.dart';


/// LoginScreen
/// ===========
/// Built-in login screen. Shown when:
/// - No session exists and no known accounts are found
/// - User explicitly chooses "Use a different account" on the picker
/// - Session expired (shows [sessionExpiredMessage] if provided)
/// - Password was reset (shows [showPasswordResetSuccess] banner)
///
/// Replaces this screen entirely by providing [CustomAuthScreens.loginScreenBuilder].
class LoginScreen extends StatefulWidget {
  final MerkadoAuthConfig config;
  final String? errorMessage;
  final String? sessionExpiredMessage;
  final bool showPasswordResetSuccess;

  const LoginScreen({
    super.key,
    required this.config,
    this.errorMessage,
    this.sessionExpiredMessage,
    this.showPasswordResetSuccess = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final theme = Theme.of(context);
    final config = widget.config;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Show error snackbar — cubit stays on login screen for error states
          state.whenOrNull(
            error: (message) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            ),
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ───────────────────────────────────────────────
                    if (config.appLogo != null)
                      Center(
                        child: Image(
                          image: config.appLogo!,
                          height: config.logoHeight,
                        ),
                      ),

                    const SizedBox(height: 40),

                    // ── Session expired banner ─────────────────────────────
                    if (widget.sessionExpiredMessage != null)
                      _Banner(
                        message: widget.sessionExpiredMessage!,
                        color: Colors.orange.shade50,
                        borderColor: Colors.orange,
                        icon: Icons.info_outline,
                      ),

                    // ── Password reset success banner ──────────────────────
                    if (widget.showPasswordResetSuccess)
                      const _Banner(
                        message: 'Password reset successfully. Please log in.',
                        color: Color(0xFFE8F5E9),
                        borderColor: Colors.green,
                        icon: Icons.check_circle_outline,
                      ),

                    Text(
                      'Sign in to ${config.appName}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Email field ────────────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Password field ─────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(cubit),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),

                    // ── Forgot password link ───────────────────────────────
                    if (config.features.forgotPassword)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: ForgotPasswordScreen(config: config),
                              ),
                            ),
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── Login button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(cubit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              config.primaryColor ?? theme.colorScheme.primary,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sign up link ───────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: SignupScreen(config: config),
                              ),
                            ),
                          ),
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),

                    // ── Terms and Privacy ──────────────────────────────────
                    if (config.termsUrl != null || config.privacyUrl != null)
                      _TermsFooter(config: config),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable info banner — used for session expired and reset success messages.
class _Banner extends StatelessWidget {
  final String message;
  final Color color;
  final Color borderColor;
  final IconData icon;

  const _Banner({
    required this.message,
    required this.color,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

/// Terms of service and privacy policy footer links.
class _TermsFooter extends StatelessWidget {
  final MerkadoAuthConfig config;
  const _TermsFooter({required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            const Text('By continuing, you agree to our '),
            if (config.termsUrl != null)
              GestureDetector(
                onTap: () {/* open termsUrl in WebView */},
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (config.termsUrl != null && config.privacyUrl != null)
              const Text(' and '),
            if (config.privacyUrl != null)
              GestureDetector(
                onTap: () {/* open privacyUrl in WebView */},
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}