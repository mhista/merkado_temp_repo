import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/dashed_container.dart';
import '../../../../core/widgets/kyc_page_banner.dart';
import '../../data/models/kyc_page_title_model.dart';
import '../bloc/kyc_bloc.dart';
import '../widgets/basic_info_bar.dart';
import '../widgets/basic_info_input.dart';
import '../widgets/basic_info_show_limit.dart';

class Tier2EnhancedKycPage extends StatefulWidget {
  const Tier2EnhancedKycPage({super.key});

  @override
  State<Tier2EnhancedKycPage> createState() => _Tier2EnhancedKycPageState();
}

class _Tier2EnhancedKycPageState extends State<Tier2EnhancedKycPage> {
  final _formKey = GlobalKey<FormState>();
  final _bvnController = TextEditingController();
  String? _selfiePath;

  @override
  Widget build(BuildContext context) {
    return KycPageBanner(
      pageTitle: thirdPageTitle.copyWith(pageButton: _submit),
      pageBody: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycTierSubmitSuccess && state.tierId == 2) {
            Navigator.pushReplacementNamed(context, '/tier3');
          }
          if (state is KycError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: AppSpacing.md),
              BasicInfoBar(
                formKey: _formKey,
                label: '1',
                title: 'Bank Details',
                subTitle: 'BVN and date of birth',
                cardBody: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // const SizedBox(height: AppSpacing.md),
                      BasicInfoInput(
                        formKey: _formKey,
                        caption: 'BANK DETAILS (BVN) *',
                        controller: _bvnController,
                        textHint: 'e.g. 12345678901',
                        isReadOnly: false,
                        helperText: 'Bank Verification Number — 11 digits',
                        checkValid: ValidationUtils.validateBvn,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              BasicInfoBar(
                formKey: _formKey,
                label: '2',
                title: 'Selfie',
                subTitle: 'Used for biometric comparison',
                cardBody: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: DashedContainer(
                        height: 200,
                        width: double.infinity,
                        borderColor: Theme.of(context).dividerColor,
                        borderRadius: AppRadius.lg,
                        color: Theme.of(context).cardColor,
                        child: _selfiePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 48,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Take or upload selfie',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                    ),
                                    child: Text(
                                      'Look directly at the camera. Face must be clearly visible and well-lit.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 48,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ShowLimitActivated(limit: 'Up to ₦5,000,000'),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() => _selfiePath = file.path);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selfiePath != null) {
      context.read<KycBloc>().add(
        SubmitTier2(_bvnController.text, _selfiePath!),
      );
    } else if (_selfiePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please take a selfie')));
    }
  }
}
