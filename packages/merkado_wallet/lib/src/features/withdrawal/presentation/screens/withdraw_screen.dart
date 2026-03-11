import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/withdrawal_cubit.dart';
import '../../domain/models/bank_account.dart';
import '../../domain/models/withdrawal_record.dart';
import '../../../../core/config/merkado_wallet_config.dart';
import 'add_bank_account_screen.dart';
import 'pin_entry_sheet.dart';

/// WithdrawScreen
/// ==============
/// Withdrawal flow:
///   1. User selects amount
///   2. User picks or adds a bank account
///   3. PIN entry sheet slides up (if pinLock enabled)
///   4. Withdrawal request submitted
class WithdrawScreen extends StatefulWidget {
  final MerkadoWalletConfig config;
  final WithdrawalCubit withdrawalCubit;

  const WithdrawScreen({
    super.key,
    required this.config,
    required this.withdrawalCubit,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BankAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    widget.withdrawalCubit.loadBankAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String get _symbol => widget.config.currency.symbol;
  Color get _primary => widget.config.effectivePrimary;

  void _proceed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a bank account'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null) return;

    // Show PIN entry if required
    if (widget.config.features.pinLock) {
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PinEntrySheet(
          config: widget.config,
          title: 'Enter wallet PIN',
          subtitle: 'Confirm your PIN to proceed with withdrawal',
        ),
      );
      if (confirmed != true) return;
    }

    // Submit withdrawal
    widget.withdrawalCubit.requestWithdrawal(
      bankAccountId: _selectedAccount!.id,
      amount: amount,
      bankAccount: _selectedAccount!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Withdraw',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: BlocConsumer<WithdrawalCubit, WithdrawalState>(
        bloc: widget.withdrawalCubit,
        listener: (context, state) {
          state.maybeMap(
            withdrawalSuccess: (_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Withdrawal submitted successfully'),
                backgroundColor: _primary,
              ));
              Navigator.of(context).pop();
            },
            error: (s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(s.message),
              backgroundColor: Colors.red,
            )),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final accounts = state.maybeMap(
            bankAccountsLoaded: (s) => s.accounts,
            orElse: () => <BankAccount>[],
          );
          final isLoading = state.maybeMap(
            loading: (_) => true,
            orElse: () => false,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount input
                  _SectionLabel('Amount'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                        fontSize: 24.sp, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      prefixText: '$_symbol ',
                      prefixStyle: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                      hintText: '0',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: _primary, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter an amount';
                      final d = double.tryParse(v);
                      if (d == null || d <= 0) return 'Enter a valid amount';
                      if (d < 100) return 'Minimum is ${_symbol}100';
                      return null;
                    },
                  ),

                  SizedBox(height: 28.h),

                  // Bank account selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('Withdraw to'),
                      TextButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: widget.withdrawalCubit,
                              child: AddBankAccountScreen(
                                config: widget.config,
                                withdrawalCubit: widget.withdrawalCubit,
                              ),
                            ),
                          ));
                          widget.withdrawalCubit.loadBankAccounts();
                        },
                        icon: Icon(Icons.add, size: 16.sp),
                        label: Text('Add account',
                            style: TextStyle(fontSize: 13.sp)),
                        style: TextButton.styleFrom(foregroundColor: _primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  if (accounts.isEmpty && !isLoading)
                    _NoAccountsPlaceholder(primary: _primary, onAdd: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: widget.withdrawalCubit,
                          child: AddBankAccountScreen(
                            config: widget.config,
                            withdrawalCubit: widget.withdrawalCubit,
                          ),
                        ),
                      ));
                    })
                  else
                    Column(
                      children: accounts.map((account) {
                        final isSelected = _selectedAccount?.id == account.id;
                        return _BankAccountTile(
                          account: account,
                          isSelected: isSelected,
                          primary: _primary,
                          onTap: () => setState(
                              () => _selectedAccount = account),
                          onDelete: () =>
                              widget.withdrawalCubit.deleteBankAccount(account.id),
                        );
                      }).toList(),
                    ),

                  SizedBox(height: 40.h),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _proceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
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
                          : Text('Continue',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600)),
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
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      );
}

class _BankAccountTile extends StatelessWidget {
  final BankAccount account;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BankAccountTile({
    required this.account,
    required this.isSelected,
    required this.primary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: isSelected ? primary.withOpacity(0.04) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance,
                  size: 18.sp, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.bankName,
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  Text(account.displayLabel,
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade500)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primary, size: 20.sp),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline,
                  size: 18.sp, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAccountsPlaceholder extends StatelessWidget {
  final Color primary;
  final VoidCallback onAdd;

  const _NoAccountsPlaceholder({required this.primary, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_outlined,
              size: 36.sp, color: Colors.grey.shade400),
          SizedBox(height: 8.h),
          Text('No bank accounts added yet',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 14.sp)),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primary),
              foregroundColor: primary,
            ),
            child: const Text('Add bank account'),
          ),
        ],
      ),
    );
  }
}