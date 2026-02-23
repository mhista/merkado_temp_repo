import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_auth/src/features/auth/presentation/cubit/auth_cubit.dart';

/// OnboardingScreen
/// ================
/// Shown after successful email OTP verification, before the user is
/// considered fully authenticated.
///
/// Collects: firstName, lastName, phone, country, and an optional avatar URL.
/// On submit, calls [AuthCubit.completeOnboarding] → POST /onboarding/complete.
/// On success, cubit emits [AuthState.authenticated] and [AuthShell] pops.
///
/// MULTI-STEP FORM:
///   Step 1 — Name        (firstName + lastName)
///   Step 2 — Contact     (phone + country)
///   Step 3 — Avatar      (optional, can skip)
///
/// TERMINATED STATE RESUMPTION:
/// If the app is killed mid-onboarding, [AuthCubit._checkStartupSession]
/// detects [isEmailVerified=true] + [isOnboardingCompleted=false] and
/// navigates back here automatically within the 30-minute window.
///
/// CUSTOM UI:
/// Replace entirely via [CustomAuthScreens.onboardingScreenBuilder].
/// Call [cubit.completeOnboarding()] from your own screen — the shell handles
/// navigation on success.
class OnboardingScreen extends StatefulWidget {
  final MerkadoAuthConfig config;

  const OnboardingScreen({super.key, required this.config});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();

  /// Avatar URL — set after image pick + upload. Null means skipped.
  String? _avatarUrl;

  /// Current active step index (0 = name, 1 = contact, 2 = avatar).
  int _currentStep = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submit(AuthCubit cubit) {
    cubit.completeOnboarding(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
      avatarUrl: _avatarUrl,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (config.appLogo != null)
                          Center(
                            child: Image(
                              image: config.appLogo!,
                              height: config.logoHeight,
                            ),
                          ),
                        const SizedBox(height: 32),
                        Text(
                          'Set up your profile',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You\'ll appear this way across ${config.appName} '
                          'and the Grascope ecosystem.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StepProgressBar(
                          currentStep: _currentStep,
                          totalSteps: 3,
                          color:
                              config.primaryColor ?? theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  // ── Step content ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildStep(context, cubit, isLoading),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(BuildContext context, AuthCubit cubit, bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _NameStep(
          key: const ValueKey('name'),
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          primaryColor: widget.config.primaryColor,
          onNext: () {
            if (_firstNameController.text.trim().length >= 2 &&
                _lastNameController.text.trim().length >= 2) {
              setState(() => _currentStep = 1);
            } else {
              _formKey.currentState?.validate();
            }
          },
        );

      case 1:
        return _ContactStep(
          key: const ValueKey('contact'),
          phoneController: _phoneController,
          countryController: _countryController,
          primaryColor: widget.config.primaryColor,
          onBack: () => setState(() => _currentStep = 0),
          onNext: () {
            final phoneOk = _phoneController.text.trim().length >= 7;
            final countryOk = _countryController.text.trim().isNotEmpty;
            if (phoneOk && countryOk) {
              setState(() => _currentStep = 2);
            } else {
              _formKey.currentState?.validate();
            }
          },
        );

      case 2:
        return _AvatarStep(
          key: const ValueKey('avatar'),
          avatarUrl: _avatarUrl,
          primaryColor: widget.config.primaryColor,
          isLoading: isLoading,
          onAvatarChanged: (url) => setState(() => _avatarUrl = url),
          onBack: () => setState(() => _currentStep = 1),
          onSubmit: () => _submit(cubit),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Step 1: Name ──────────────────────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final Color? primaryColor;
  final VoidCallback onNext;

  const _NameStep({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.primaryColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your name?',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: firstNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'First name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'First name is required';
            if (v.trim().length < 2) return 'Must be at least 2 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: lastNameController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Last name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Last name is required';
            if (v.trim().length < 2) return 'Must be at least 2 characters';
            return null;
          },
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          label: 'Continue',
          primaryColor: primaryColor,
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ── Step 2: Contact (Phone + Country) ─────────────────────────────────────────

class _ContactStep extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final Color? primaryColor;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _ContactStep({
    super.key,
    required this.phoneController,
    required this.countryController,
    required this.primaryColor,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your contact details',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Helps us show relevant vendors and services near you.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 24),

        // Phone number
        // TIP: Replace with intl_phone_number_input for a country-code picker.
        // On change: phoneController.text = formattedE164Number
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: 'e.g. +234 801 234 5678',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Phone number is required';
            if (v.trim().length < 7) return 'Enter a valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Country
        // TIP: Replace with country_picker package for production.
        // showCountryPicker() on tap, set countryController.text = country.name
        TextFormField(
          controller: countryController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.public_outlined),
            hintText: 'e.g. Nigeria, Kenya, South Africa',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Country is required';
            return null;
          },
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _PrimaryButton(
                label: 'Continue',
                primaryColor: primaryColor,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Step 3: Avatar ────────────────────────────────────────────────────────────

class _AvatarStep extends StatelessWidget {
  final String? avatarUrl;
  final Color? primaryColor;
  final bool isLoading;
  final ValueChanged<String?> onAvatarChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _AvatarStep({
    super.key,
    required this.avatarUrl,
    required this.primaryColor,
    required this.isLoading,
    required this.onAvatarChanged,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a profile photo',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Optional — you can always update this later.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 40),

        // Avatar picker
        // TIP: On tap, use image_picker to pick from gallery or camera.
        // Upload to your media service, call onAvatarChanged(cdnUrl) with result.
        Center(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    // TODO: integrate image_picker + upload here
                    // final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    // if (picked != null) {
                    //   final url = await uploadToMediaService(picked);
                    //   onAvatarChanged(url);
                    // }
                  },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person_outline,
                          size: 52, color: Colors.grey.shade400)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _PrimaryButton(
                label: 'Complete setup',
                primaryColor: primaryColor,
                isLoading: isLoading,
                onPressed: isLoading ? null : onSubmit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : onSubmit,
            child: const Text('Skip for now'),
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color color;

  const _StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index <= currentStep ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color? primaryColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.primaryColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              primaryColor ?? Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}