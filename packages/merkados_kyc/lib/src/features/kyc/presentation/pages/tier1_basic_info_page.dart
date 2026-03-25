import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/kyc_page_banner.dart';
import '../../data/models/kyc_page_title_model.dart';
import '../bloc/kyc_bloc.dart';
import '../widgets/basic_info_bar.dart';
import '../widgets/basic_info_gender_button.dart';
import '../widgets/basic_info_input.dart';
import '../widgets/basic_info_show_limit.dart';

class Tier1BasicInfoPage extends StatefulWidget {
  const Tier1BasicInfoPage({super.key});

  @override
  State<Tier1BasicInfoPage> createState() => _Tier1BasicInfoPageState();
}

class _Tier1BasicInfoPageState extends State<Tier1BasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _ninController = TextEditingController();
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return KycPageBanner(
      pageTitle: secondPageTitle.copyWith(
        buttonCaption: 'Submit & verify',
        pageButton: _submit,
      ),
      pageBody: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycTierSubmitSuccess && state.tierId == 1) {
            Navigator.pushReplacementNamed(context, '/tier2');
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
                title: 'Identity Details',
                subTitle: 'Your NIN and date of birth',
                cardBody: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Form Fields
                      BasicInfoInput(
                        formKey: _formKey,
                        caption: 'DATE OF BIRTH *',
                        controller: _dobController,
                        textHint: 'mm / dd / yyyy',
                        isReadOnly: true,
                        onDateSelect: (DateTime date) {
                          // Date selected
                        },
                        helperText:
                            'Must match your NIN records — format YYYY-MM-DD',
                        checkValid: (v) => ValidationUtils.validateRequired(
                          v,
                          'Date of birth',
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),
                      BasicInfoInput(
                        formKey: _formKey,
                        caption: 'NATIONAL ID NUMBER (NIN) *',
                        controller: _ninController,
                        textHint: 'e.g. 12345678901',
                        isReadOnly: false,
                        helperText:
                            'Your 11-digit National Identification Number',
                        checkValid: (v) => ValidationUtils.validateNin(v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'GENDER *',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GenderButton(
                            gender: 'Male',
                            icon: Icons.male,
                            isSelected: _selectedGender == 'Male',
                            onSelected: (gender) =>
                                setState(() => _selectedGender = gender),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          GenderButton(
                            gender: 'Female',
                            icon: Icons.female,
                            isSelected: _selectedGender == 'Female',
                            onSelected: (gender) =>
                                setState(() => _selectedGender = gender),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ShowLimitActivated(),
            ],
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      context.read<KycBloc>().add(
        SubmitTier1(_dobController.text, _ninController.text, _selectedGender!),
      );
    } else if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select gender')));
    }
  }
}
