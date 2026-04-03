import 'dart:io';

import 'package:common_designs/common_designs.dart';
import 'package:common_utils2/common_utils2.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:merkado_auth/merkado_auth.dart';
import 'package:merkado_ds/merkado_ds.dart';
import 'package:mix/mix.dart';
import '../../cubit/auth_cubit.dart';
import '../styles.dart';

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
  Country? selectedCountry;
  String? _avatarUrl;
  File? _selectedImageFile;

  void _submit(AuthCubit cubit) {
    cubit.completeOnboarding(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      country: selectedCountry?.name ?? 'Nigeria',
      avatarFile: _selectedImageFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            ),
          );
        },
        builder: (context, state) {
          state.maybeWhen(loading: () => true, orElse: () => false);
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 17.5,
                vertical: kToolbarHeight,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.huge,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        DeviceInfoHelper.instance.isIOS
                            ? Icons.arrow_back_ios_new
                            : Icons.arrow_back,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                    Column(
                      spacing: AppSpacing.sm,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min ,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            // spacing: AppSpacing.xs,
                            children: [
                              StyledText(
                                'Set up your profile',
                                style: LoginPageStyler.textStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ).textAlign(TextAlign.center),
                              ),
                              StyledText(
                                'Let’s start with creating your profile',
                                style: LoginPageStyler.textStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ).textAlign(TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                        // USER AVATAR
                        UserProfileImage(
                          avataUrl: _avatarUrl ?? '',
                          onImagePicked: (file) =>
                              setState(() => _selectedImageFile = file),
                        ),

                        // NAME TEXTFIELD
                        Row(
                          spacing: AppSpacing.xxs,
                          children: [
                            Expanded(
                              child: TextFieldForm(
                                controller: _firstNameController,
                                fieldName: 'First Name',
                                validator: CommonValidators.nameValidator,
                                labelText: 'First Name',
                              ),
                            ),
                            Expanded(
                              child: TextFieldForm(
                                controller: _lastNameController,
                                fieldName: 'Last Name',
                                validator: CommonValidators.nameValidator,
                                labelText: 'Last Name',
                              ),
                            ),
                          ],
                        ),
                        // SELECT COUNTRY
                        CommonDropdown.countries(
                          label: 'Select Country',
                          value: selectedCountry,
                          onChanged: (country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                          config: CommonDropdownConfig(
                            backgroundColor: Colors.transparent,
                            searchBackgroundColor: MycutLightColors.accentWhite,
                            overlayColor: MycutLightColors.accentWhite,
                            overlayBorderColor: Colors.transparent,
                          ),
                        ),
                        TextFieldForm(
                          controller: _phoneController,
                          fieldName: 'Phone Number',
                          validator: CommonValidators.phoneValidator,
                          labelText: 'Phone Number',
                        ),

                        // VERIFY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.maybeWhen(
                                  orElse: () => () {
                                    _submit(cubit);
                                  },
                                  loading: null,
                                ),
                                child: state.maybeWhen(
                                  orElse: () => const Text(
                                    'Get Started',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  loading: () =>
                                      LoadingAnimationWidget.fallingDot(
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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

class UserProfileImage extends StatefulWidget {
  final String avataUrl;
  final Function(File?) onImagePicked; // changed to nullable

  const UserProfileImage({
    super.key,
    required this.avataUrl,
    required this.onImagePicked,
  });

  @override
  State<UserProfileImage> createState() => _UserProfileImageState();
}

class _UserProfileImageState extends State<UserProfileImage> {
  File? _selectedFile;
  double? _uploadProgress; // ← New
  bool _isUploading = false; // ← New

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.maybeMap(
            orElse: () => false,
            onboardingUploading: (value) => true,
          ) ||
          previous.maybeMap(
            orElse: () => false,
            onboardingUploading: (value) => true,
          ),
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {
            setState(() {
              _isUploading = false;
              _uploadProgress = null;
            });
          },
          onboardingUploading: (progress, message) {
            setState(() {
              _isUploading = true;
              _uploadProgress = progress;
            });
          },
        );
      },
      child: DottedBorder(
        options: CircularDottedBorderOptions(
          color: AppColors.borderDark,
          strokeWidth: 1,
          dashPattern: [4, 4],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image Preview
            if (_selectedFile != null)
              CircularImage(
                padding: 0,
                file: _selectedFile,
                width: 96,
                height: 96,
                imageType: ImagesType.file,
              )
            else if (widget.avataUrl.isNotEmpty)
              CircularImage(
                padding: 0,
                image: widget.avataUrl,
                width: 96,
                height: 96,
                imageType: ImagesType.network,
              )
            else
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MycutLightColors.accentWhite,
                ),
                child: const Icon(Icons.person, size: 48, color: Colors.grey),
              ),

            // Upload Progress Overlay
            if (_isUploading && _uploadProgress != null)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress! * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Camera Button
            Positioned(
              bottom: 0,
              right: 0,
              child: SmoothEdgeContainer(
                onTap: _pickImage,
                radius: 100,
                height: 28,
                width: 28,
                padding: EdgeInsets.zero,
                backgroundColor: MycutLightColors.textPrimary,
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await MediaUtils.pickImageFromGallery();
    if (result.isSuccess && result.value != null) {
      setState(() {
        _selectedFile = result.value;
        _uploadProgress = null;
        _isUploading = false;
      });
      widget.onImagePicked(result.value);
    }
  }
}
