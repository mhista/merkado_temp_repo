import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../merkado_auth.dart';
import '../cubit/auth_cubit.dart';
import 'signup/signup_screen.dart';

/// AccountPickerScreen
/// ===================
/// Shown in two modes controlled by [isLocalAccounts]:
///
/// LOCAL MODE (isLocalAccounts: true)
///   Triggered after logout or on startup when this app has previously
///   signed-in accounts in local storage. The user recognises these as
///   "their accounts" for this app.
///   Copy: "Welcome back" / "Switch account"
///   Action: cubit.continueAsAccount() — exchanges stored refresh token.
///   Bottom options: "Sign in with a different account", "Create new account"
///
/// CROSS-APP SSO MODE (isLocalAccounts: false)
///   Triggered when no local accounts exist but other Grascope apps on
///   this device have active sessions. The user may or may not recognise
///   these accounts as usable here.
///   Copy: "Continue as [name]" / "Found your Grascope accounts"
///   Action: cubit.continueAsAccount() — same token exchange.
///   Bottom options: "Use a different account", "Create new account"
class AccountPickerScreen extends StatelessWidget {
  final List<GrascopeSessionHint> accounts;
  final MerkadoAuthConfig config;

  /// true  → local accounts for this app (post-logout / returning user)
  /// false → cross-app SSO accounts from other Grascope apps
  final bool isLocalAccounts;

  const AccountPickerScreen({
    super.key,
    required this.accounts,
    required this.config,
    this.isLocalAccounts = false,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final theme = Theme.of(context);
    final isSingle = accounts.length == 1;

    // ── Copy varies by mode ──────────────────────────────────────────────────
    final headline = isLocalAccounts
        ? (isSingle ? 'Welcome back' : 'Switch account')
        : (isSingle ? 'Continue as ${accounts.first.displayName}' : 'Your Grascope accounts');

    final subtitle = isLocalAccounts
        ? (isSingle
            ? 'Sign in as ${accounts.first.displayName}'
            : 'Select an account to continue to ${config.appName}')
        : (isSingle
            ? 'We found a Grascope account on this device'
            : 'We found Grascope accounts on this device. Select one to continue.');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              if (config.appLogo != null)
                Center(
                  child: Image(
                    image: Image.asset( config.appLogo!).image,
                    height: config.logoHeight,
                  ),
                ),

              const SizedBox(height: 40),

              Text(
                headline,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 32),

              // ── Account tiles ─────────────────────────────────────────────
              ...accounts.map((hint) => _AccountTile(
                    hint: hint,
                    onTap: () => cubit.continueAsAccount(hint),
                  )),

              const Divider(height: 32),

              // ── Other options ─────────────────────────────────────────────
              _OtherOptionTile(
                icon: Icons.person_outline,
                label: isLocalAccounts
                    ? 'Sign in with a different account'
                    : 'Use a different account',
                onTap: () => cubit.emit(const AuthState.unauthenticated()),
              ),

              _OtherOptionTile(
                icon: Icons.person_add_outlined,
                label: 'Create new account',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: SignupScreen(config: config),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final GrascopeSessionHint hint;
  final VoidCallback onTap;

  const _AccountTile({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage:
              hint.avatarUrl.isNotEmpty ? NetworkImage(hint.avatarUrl) : null,
          child: hint.avatarUrl.isEmpty
              ? Text(hint.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(
          hint.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(hint.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _OtherOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OtherOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}