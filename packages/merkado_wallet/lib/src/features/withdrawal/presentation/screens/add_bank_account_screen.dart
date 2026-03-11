import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/withdrawal_cubit.dart';
import '../../domain/models/bank_account.dart';
import '../../../../core/config/merkado_wallet_config.dart';
import '../../../../services/banks/nigerian_bank_service.dart';

/// AddBankAccountScreen
/// ====================
/// Multi-currency bank account addition screen.
/// - NGN: bank code selector (from Paystack public API), account number
/// - GBP: sort code + account number (FPS/BACS)
/// - EUR: IBAN + SEPA
/// - USD: account number + SWIFT code
class AddBankAccountScreen extends StatefulWidget {
  final MerkadoWalletConfig config;
  final WithdrawalCubit withdrawalCubit;

  const AddBankAccountScreen({
    super.key,
    required this.config,
    required this.withdrawalCubit,
  });

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> get _tabs => widget.config.features.supportedWithdrawalCurrencies;
  Color get _primary => widget.config.effectivePrimary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Bank Account',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: _tabs.length > 1
            ? TabBar(
                controller: _tabController,
                labelColor: _primary,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: _primary,
                tabs: _tabs.map((c) => Tab(text: c)).toList(),
              )
            : null,
      ),
      body: BlocConsumer<WithdrawalCubit, WithdrawalState>(
        bloc: widget.withdrawalCubit,
        listener: (context, state) {
          state.maybeMap(
            bankAccountAdded: (_) => Navigator.of(context).pop(),
            error: (s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(s.message),
              backgroundColor: Colors.red,
            )),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeMap(
            loading: (_) => true,
            orElse: () => false,
          );

          if (_tabs.length == 1) {
            return _formForCurrency(_tabs[0], isLoading);
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs
                .map((c) => _formForCurrency(c, isLoading))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _formForCurrency(String currency, bool isLoading) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return _NgnBankForm(
          primary: _primary,
          isLoading: isLoading,
          onSubmit: (data) => widget.withdrawalCubit.addBankAccount(
            currency: BankCurrency.ngn,
            data: data,
          ),
        );
      case 'GBP':
        return _GbpBankForm(
          primary: _primary,
          isLoading: isLoading,
          onSubmit: (data) => widget.withdrawalCubit.addBankAccount(
            currency: BankCurrency.gbp,
            data: data,
          ),
        );
      case 'EUR':
        return _EurBankForm(
          primary: _primary,
          isLoading: isLoading,
          onSubmit: (data) => widget.withdrawalCubit.addBankAccount(
            currency: BankCurrency.eur,
            data: data,
          ),
        );
      case 'USD':
        return _UsdBankForm(
          primary: _primary,
          isLoading: isLoading,
          onSubmit: (data) => widget.withdrawalCubit.addBankAccount(
            currency: BankCurrency.usd,
            data: data,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── NGN Form ──────────────────────────────────────────────────────────────────

class _NgnBankForm extends StatefulWidget {
  final Color primary;
  final bool isLoading;
  final void Function(Map<String, dynamic>) onSubmit;

  const _NgnBankForm({
    required this.primary,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<_NgnBankForm> createState() => _NgnBankFormState();
}

class _NgnBankFormState extends State<_NgnBankForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  SupportedBank? _selectedBank;
  List<SupportedBank> _banks = [];
  bool _loadingBanks = true;
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final banks = await NigerianBankService.instance.getBanks();
    if (mounted) setState(() {
      _banks = banks;
      _loadingBanks = false;
    });
  }

  @override
  void dispose() {
    _accountNumber.dispose();
    _accountName.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) return;
    widget.onSubmit({
      'bankName': _selectedBank!.name,
      'bankCode': _selectedBank!.code,
      'accountNumber': _accountNumber.text.trim(),
      'accountName': _accountName.text.trim(),
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'beneficiaryType': 'individual',
      'isDefault': _isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Bank selector
            _loadingBanks
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<SupportedBank>(
                    value: _selectedBank,
                    hint: const Text('Select bank'),
                    decoration: _inputDeco('Bank'),
                    items: _banks
                        .map((b) => DropdownMenuItem(
                              value: b,
                              child: Text(b.name),
                            ))
                        .toList(),
                    onChanged: (b) => setState(() => _selectedBank = b),
                    validator: (v) => v == null ? 'Select a bank' : null,
                  ),
            SizedBox(height: 14.h),
            _WalletTextField(
              controller: _accountNumber,
              label: 'Account Number',
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.length < 10
                  ? 'Enter a valid 10-digit account number'
                  : null,
            ),
            SizedBox(height: 14.h),
            _WalletTextField(
                controller: _accountName, label: 'Account Name'),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _WalletTextField(
                      controller: _firstName, label: 'First Name'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _WalletTextField(
                      controller: _lastName, label: 'Last Name'),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _WalletTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: 14.h),
            _WalletTextField(
                controller: _phone,
                label: 'Phone (e.g. +2348012345678)',
                keyboardType: TextInputType.phone),
            SizedBox(height: 10.h),
            SwitchListTile(
              value: _isDefault,
              title: const Text('Set as default account'),
              activeColor: widget.primary,
              onChanged: (v) => setState(() => _isDefault = v),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: 24.h),
            _SubmitButton(
                label: 'Add Account',
                primary: widget.primary,
                isLoading: widget.isLoading,
                onTap: _submit),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: widget.primary, width: 2),
        ),
      );
}

// ── GBP Form ──────────────────────────────────────────────────────────────────

class _GbpBankForm extends StatefulWidget {
  final Color primary;
  final bool isLoading;
  final void Function(Map<String, dynamic>) onSubmit;
  const _GbpBankForm({required this.primary, required this.isLoading, required this.onSubmit});
  @override State<_GbpBankForm> createState() => _GbpBankFormState();
}
class _GbpBankFormState extends State<_GbpBankForm> {
  final _formKey = GlobalKey<FormState>();
  final _bankName = TextEditingController();
  final _sortCode = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();
  final _swift = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _isDefault = true;

  @override dispose() {
    for (final c in [_bankName,_sortCode,_accountNumber,_accountName,_swift,_firstName,_lastName,_email,_phone]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'bankName': _bankName.text.trim(),
      'sortCode': _sortCode.text.trim(),
      'accountNumber': _accountNumber.text.trim(),
      'accountName': _accountName.text.trim(),
      'paymentScheme': 'fps',
      'bankSwiftCode': _swift.text.trim(),
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'beneficiaryType': 'individual',
      'isDefault': _isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(children: [
          _WalletTextField(controller: _bankName, label: 'Bank Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _sortCode, label: 'Sort Code (e.g. 040004)', keyboardType: TextInputType.number),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _accountNumber, label: '8-digit Account Number', keyboardType: TextInputType.number),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _accountName, label: 'Account Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _swift, label: 'SWIFT/BIC Code (optional)'),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(child: _WalletTextField(controller: _firstName, label: 'First Name')),
            SizedBox(width: 12.w),
            Expanded(child: _WalletTextField(controller: _lastName, label: 'Last Name')),
          ]),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _phone, label: 'Phone (+447...)', keyboardType: TextInputType.phone),
          SizedBox(height: 10.h),
          SwitchListTile(value: _isDefault, title: const Text('Set as default'), activeColor: widget.primary, onChanged: (v) => setState(() => _isDefault = v), contentPadding: EdgeInsets.zero),
          SizedBox(height: 24.h),
          _SubmitButton(label: 'Add GBP Account', primary: widget.primary, isLoading: widget.isLoading, onTap: _submit),
        ]),
      ),
    );
  }
}

// ── EUR Form ──────────────────────────────────────────────────────────────────

class _EurBankForm extends StatefulWidget {
  final Color primary; final bool isLoading; final void Function(Map<String, dynamic>) onSubmit;
  const _EurBankForm({required this.primary, required this.isLoading, required this.onSubmit});
  @override State<_EurBankForm> createState() => _EurBankFormState();
}
class _EurBankFormState extends State<_EurBankForm> {
  final _formKey = GlobalKey<FormState>();
  final _bankName = TextEditingController();
  final _iban = TextEditingController(); // accountNumber field
  final _accountName = TextEditingController();
  final _country = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _isDefault = true;

  @override dispose() {
    for (final c in [_bankName,_iban,_accountName,_country,_firstName,_lastName,_email,_phone]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'bankName': _bankName.text.trim(),
      'accountNumber': _iban.text.trim(),
      'accountName': _accountName.text.trim(),
      'paymentScheme': 'sepa',
      'country': _country.text.trim(),
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'beneficiaryType': 'individual',
      'isDefault': _isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(children: [
          _WalletTextField(controller: _bankName, label: 'Bank Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _iban, label: 'IBAN (e.g. DE89370400440532013000)'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _accountName, label: 'Account Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _country, label: 'Country Code (e.g. DE)'),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(child: _WalletTextField(controller: _firstName, label: 'First Name')),
            SizedBox(width: 12.w),
            Expanded(child: _WalletTextField(controller: _lastName, label: 'Last Name')),
          ]),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _phone, label: 'Phone', keyboardType: TextInputType.phone),
          SizedBox(height: 10.h),
          SwitchListTile(value: _isDefault, title: const Text('Set as default'), activeColor: widget.primary, onChanged: (v) => setState(() => _isDefault = v), contentPadding: EdgeInsets.zero),
          SizedBox(height: 24.h),
          _SubmitButton(label: 'Add EUR Account', primary: widget.primary, isLoading: widget.isLoading, onTap: _submit),
        ]),
      ),
    );
  }
}

// ── USD Form ──────────────────────────────────────────────────────────────────

class _UsdBankForm extends StatefulWidget {
  final Color primary; final bool isLoading; final void Function(Map<String, dynamic>) onSubmit;
  const _UsdBankForm({required this.primary, required this.isLoading, required this.onSubmit});
  @override State<_UsdBankForm> createState() => _UsdBankFormState();
}
class _UsdBankFormState extends State<_UsdBankForm> {
  final _formKey = GlobalKey<FormState>();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _accountName = TextEditingController();
  final _swift = TextEditingController();
  final _bankCode = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _isDefault = true;

  @override dispose() {
    for (final c in [_bankName,_accountNumber,_accountName,_swift,_bankCode,_firstName,_lastName,_email,_phone]) c.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit({
      'bankName': _bankName.text.trim(),
      'accountNumber': _accountNumber.text.trim(),
      'accountName': _accountName.text.trim(),
      'paymentScheme': 'swift',
      'bankSwiftCode': _swift.text.trim(),
      'bankCode': _bankCode.text.trim(),
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'beneficiaryType': 'individual',
      'isDefault': _isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(children: [
          _WalletTextField(controller: _bankName, label: 'Bank Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _accountNumber, label: 'Account Number', keyboardType: TextInputType.number),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _accountName, label: 'Account Name'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _swift, label: 'SWIFT/BIC Code (e.g. BOFAUS3N)'),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _bankCode, label: 'Routing/Bank Code (e.g. 021000021)'),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(child: _WalletTextField(controller: _firstName, label: 'First Name')),
            SizedBox(width: 12.w),
            Expanded(child: _WalletTextField(controller: _lastName, label: 'Last Name')),
          ]),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
          SizedBox(height: 14.h),
          _WalletTextField(controller: _phone, label: 'Phone (+1...)', keyboardType: TextInputType.phone),
          SizedBox(height: 10.h),
          SwitchListTile(value: _isDefault, title: const Text('Set as default'), activeColor: widget.primary, onChanged: (v) => setState(() => _isDefault = v), contentPadding: EdgeInsets.zero),
          SizedBox(height: 24.h),
          _SubmitButton(label: 'Add USD Account', primary: widget.primary, isLoading: widget.isLoading, onTap: _submit),
        ]),
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _WalletTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _WalletTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final Color primary;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.primary,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }
}