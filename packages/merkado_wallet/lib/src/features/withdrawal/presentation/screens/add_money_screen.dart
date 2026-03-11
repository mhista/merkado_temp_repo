import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../merkado_wallet.dart';
// import '../../../../core/config/merkado_wallet_config.dart';

/// AddMoneyScreen
/// ==============
/// Allows user to fund their wallet.
/// In demo mode: instant credit via POST /v1/wallet/demo/fund
/// In production: initiates Paystack/Fincra checkout via POST /v1/wallet/fund
class AddMoneyScreen extends StatefulWidget {
  final MerkadoWalletConfig config;
  final WalletCubit walletCubit;

  const AddMoneyScreen({
    super.key,
    required this.config,
    required this.walletCubit,
  });

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double? _parsedAmount;

  // Quick amount presets
  static const _presets = [1000.0, 2000.0, 5000.0, 10000.0, 20000.0, 50000.0];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String get _symbol => widget.config.currency.symbol;
  Color get _primary => widget.config.effectivePrimary;
  bool get _isDemo => widget.config.features.demoMode;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) return;

    if (_isDemo) {
      widget.walletCubit.demoAddMoney(amount: amount);
    } else {
      widget.walletCubit.initiateAddMoney(amount: amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Money',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        bloc: widget.walletCubit,
        listener: (context, state) {
          state.maybeMap(
            demoFundSuccess: (_) => Navigator.of(context).pop(),
            fundInitiated: (s) {
              // Open checkout URL in WebView/browser
              // The consuming app handles URL launching
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Opening payment page...'),
                backgroundColor: _primary,
              ));
            },
            error: (s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(s.message),
              backgroundColor: Colors.red,
            )),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeMap(
            updating: (_) => true,
            orElse: () => false,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isDemo)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16.sp, color: Colors.orange),
                          SizedBox(width: 8.w),
                          Text(
                            'Demo mode — no real money involved',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 28.h),

                  Text(
                    'Enter amount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Amount input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixText: '$_symbol ',
                      prefixStyle: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: _primary, width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter an amount';
                      final d = double.tryParse(v);
                      if (d == null || d <= 0) return 'Enter a valid amount';
                      if (d < 100) return 'Minimum amount is ${_symbol}100';
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Quick-select presets
                  Text(
                    'Quick select',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _presets.map((preset) {
                      return _PresetChip(
                        label: '$_symbol${preset.toInt()}',
                        primary: _primary,
                        onTap: () {
                          _amountController.text = preset.toInt().toString();
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 40.h),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
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
                          : Text(
                              _isDemo ? 'Add Money (Demo)' : 'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
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
}

class _PresetChip extends StatelessWidget {
  final String label;
  final Color primary;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: primary.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(100.r),
          color: primary.withOpacity(0.06),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}