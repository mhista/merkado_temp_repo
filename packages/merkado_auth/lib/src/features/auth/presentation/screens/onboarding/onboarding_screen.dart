import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_auth/src/features/auth/presentation/cubit/auth_cubit.dart';


/// OnboardingScreen
/// ================
/// Shown after successful email OTP verification, before the user is
/// considered fully authenticated.
///
/// Collects: firstName, lastName, country, and an optional avatar URL.
/// On submit, calls [AuthCubit.completeOnboarding] → POST /onboarding/complete.
/// On success, cubit emits [AuthState.authenticated] and the [AuthShell] pops.
///
/// MULTI-STEP FORM:
///   Step 1 — Name (firstName + lastName)
///   Step 2 — Country
///   Step 3 — Avatar (optional, can skip)
///
/// TERMINATED STATE RESUMPTION:
/// If the app is killed mid-onboarding, [AuthCubit._checkStartupSession]
/// detects [isEmailVerified=true] + [isOnboardingCompleted=false] and
/// navigates back here automatically. No data is pre-filled since the
/// backend hasn't received it yet — the user simply fills it in again.
///
/// CUSTOM UI:
/// Replace entirely via [CustomAuthScreens.onboardingScreenBuilder].
/// The cubit is passed to your screen so you call [cubit.completeOnboarding]
/// from your own UI.
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
  final _countryController = TextEditingController();

  /// Avatar URL — set after image pick + upload. Null means skipped.
  /// Integrate your image_picker + upload flow here, set [_avatarUrl]
  /// with the returned URL from your media service.
  String? _avatarUrl;

  /// Current active step index (0 = name, 1 = country, 2 = avatar).
  int _currentStep = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// Submits the completed onboarding form.
  /// Called from the final step or the "Skip" button on the avatar step.
  void _submit(AuthCubit cubit) {
    cubit.completeOnboarding(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
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
          // Show error inline — stay on screen for the user to retry
          state.whenOrNull(
            error: (message) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
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
                  // ── Header (always visible) ───────────────────────────
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
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Step progress bar
                        _StepProgressBar(
                          currentStep: _currentStep,
                          totalSteps: 3,
                          color: config.primaryColor ?? theme.colorScheme.primary,
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

  /// Renders the current step widget.
  Widget _buildStep(BuildContext context, AuthCubit cubit, bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _NameStep(
          key: const ValueKey('name'),
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          primaryColor: widget.config.primaryColor,
          onNext: () {
            // Validate only the name fields before advancing
            if (_firstNameController.text.trim().length >= 2 &&
                _lastNameController.text.trim().length >= 2) {
              setState(() => _currentStep = 1);
            } else {
              _formKey.currentState?.validate();
            }
          },
        );

      case 1:
        return _CountryStep(
          key: const ValueKey('country'),
          countryController: _countryController,
          primaryColor: widget.config.primaryColor,
          onBack: () => setState(() => _currentStep = 0),
          onNext: () {
            if (_countryController.text.trim().isNotEmpty) {
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

        // First name
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

        // Last name
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

// ── Step 2: Country ───────────────────────────────────────────────────────────

class _CountryStep extends StatelessWidget {
  final TextEditingController countryController;
  final Color? primaryColor;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _CountryStep({
    super.key,
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
          'Where are you based?',
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

        // Country field.
        // TIP: Replace with a country_picker package for production —
        // e.g. country_picker: ^2.0.0. Call showCountryPicker() on tap
        // and set the controller text from the selected Country object.
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
        // Upload the image to your media service and call onAvatarChanged(url)
        // with the returned CDN URL.
        Center(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    // TODO: integrate image_picker here
                    // Example:
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
                      ? Icon(
                          Icons.person_outline,
                          size: 52,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
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

        // Skip avatar — submits without an avatar URL
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

// ── Shared reusable widgets ───────────────────────────────────────────────────

/// Three-segment progress bar showing current onboarding step.
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
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

/// Reusable primary action button used across all onboarding steps.
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
                  strokeWidth: 2,
                  color: Colors.white,
                ),
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