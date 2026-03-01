import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';


import '../cubit/auth_cubit.dart';
import 'signup/signup_screen.dart';

/// AccountPickerScreen
/// ===================
/// Shown at startup when one or more known Grascope accounts are detected
/// in shared secure storage from other Grascope apps on this device.
///
/// For a single account, shows "Continue as [name]".
/// For multiple accounts, shows a full picker list.
/// Always includes options to sign in with a different account or create new.
class AccountPickerScreen extends StatelessWidget {
  final List<GrascopeSessionHint> accounts;
  final MerkadoAuthConfig config;

  const AccountPickerScreen({
    super.key,
    required this.accounts,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final theme = Theme.of(context);
    final isSingle = accounts.length == 1;

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
                isSingle ? 'Welcome back' : 'Choose an account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                isSingle
                    ? 'Continue to ${config.appName} with your Grascope account'
                    : 'Select an account to continue to ${config.appName}',
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
                label: 'Use a different account',
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