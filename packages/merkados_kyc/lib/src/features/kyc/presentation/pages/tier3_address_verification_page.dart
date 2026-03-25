import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/kyc_page_banner.dart';
import '../../data/models/kyc_page_title_model.dart';
import '../bloc/kyc_bloc.dart';
import '../widgets/address_power_type_button.dart';
import '../widgets/basic_info_bar.dart';
import '../widgets/basic_info_drop.dart';
import '../widgets/basic_info_input.dart';
import '../widgets/basic_info_show_limit.dart';

class Tier3AddressVerificationPage extends StatefulWidget {
  const Tier3AddressVerificationPage({super.key});

  @override
  State<Tier3AddressVerificationPage> createState() =>
      _Tier3AddressVerificationPageState();
}

class _Tier3AddressVerificationPageState
    extends State<Tier3AddressVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _accountController = TextEditingController();
  final _meterController = TextEditingController();
  String? _selectedProvider;
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return KycPageBanner(
      pageTitle: fourthPageTitle.copyWith(pageButton: _submit),
      pageBody: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycTierSubmitSuccess && state.tierId == 3) {
            Navigator.pushReplacementNamed(context, '/success');
          }
          if (state is KycError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: AppSpacing.md),
                BasicInfoBar(
                  formKey: _formKey,
                  label: '1',
                  title: 'Residential Address',
                  subTitle: 'Where you currently live',
                  cardBody: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      BasicInfoInput(
                        formKey: _formKey,
                        caption: 'ADDRESS *',
                        controller: _addressController,
                        textHint:
                            'e.g. 14 Adeola Odeku St, Victoria Island, Lagos',
                        isReadOnly: false,
                        inputType: TextInputType.streetAddress,
                        checkValid: (v) =>
                            ValidationUtils.validateRequired(v, 'Address'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                BasicInfoBar(
                  formKey: _formKey,
                  label: '2',
                  title: 'Utility Provider',
                  subTitle: 'Select your electricity provider',
                  cardBody: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      BasicInfoDrop(
                        formKey: _formKey,
                        caption: 'UTILITY PROVIDER',
                        initial: _selectedProvider,
                        isReadOnly: false,
                        onSelect: (v) => setState(() => _selectedProvider = v),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'UTILITY TYPE *',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          AddressPowerTypeButton(
                            type: 'PrePaid',
                            icon: Icons.bolt,
                            isSelected: _selectedType == 'PrePaid',
                            onSelected: (v) =>
                                setState(() => _selectedType = v),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          AddressPowerTypeButton(
                            type: 'PostPaid',
                            icon: Icons.history,
                            isSelected: _selectedType == 'PostPaid',
                            onSelected: (v) =>
                                setState(() => _selectedType = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                BasicInfoBar(
                  formKey: _formKey,
                  label: '3',
                  title: 'Account Details',
                  subTitle: 'At least one is required',
                  cardBody: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: BasicInfoInput(
                              formKey: _formKey,
                              caption: 'ACCOUNT NO.',
                              controller: _accountController,
                              textHint: 'Account no.',
                              isReadOnly: false,
                              digits: 20,
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: BasicInfoInput(
                              formKey: _formKey,
                              caption: 'METER NO.',
                              controller: _meterController,
                              textHint: 'Meter no.',
                              isReadOnly: false,
                              digits: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Provide your account number or meter number for the utility lookup.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ShowLimitActivated(limit: 'Unlimited'),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      context.read<KycBloc>().add(
        SubmitTier3(
          _addressController.text,
          _selectedProvider!,
          _selectedType!,
          _accountController.text,
          _meterController.text,
        ),
      );
    } else if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select utility type')),
      );
    }
  }
}
