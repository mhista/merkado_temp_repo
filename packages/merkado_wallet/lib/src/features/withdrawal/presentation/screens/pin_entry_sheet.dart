import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/merkado_wallet_config.dart';

/// PinEntrySheet
/// =============
/// Modal bottom sheet for PIN entry before protected actions.
/// Returns [true] if confirmed, [null] if dismissed.
///
/// USAGE:
/// ```dart
/// final confirmed = await showModalBottomSheet<bool>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => PinEntrySheet(config: config, title: 'Enter PIN'),
/// );
/// ```
class PinEntrySheet extends StatefulWidget {
  final MerkadoWalletConfig config;
  final String title;
  final String? subtitle;

  const PinEntrySheet({
    super.key,
    required this.config,
    required this.title,
    this.subtitle,
  });

  @override
  State<PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends State<PinEntrySheet> {
  final List<String> _digits = [];
  static const int _pinLength = 4;
  bool _hasError = false;

  Color get _primary => widget.config.effectivePrimary;

  void _addDigit(String d) {
    if (_digits.length >= _pinLength) return;
    setState(() {
      _digits.add(d);
      _hasError = false;
    });
    if (_digits.length == _pinLength) {
      _onPinComplete();
    }
  }

  void _removeDigit() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  void _onPinComplete() {
    final pin = _digits.join();
    // Return the PIN to the caller — they handle verification
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w700),
                    ),
                    if (widget.subtitle != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                            fontSize: 13.sp, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (i) {
                  final filled = i < _digits.length;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? (_hasError ? Colors.red : _primary)
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),

              if (_hasError) ...[
                SizedBox(height: 8.h),
                Text('Incorrect PIN. Try again.',
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.red)),
              ],

              SizedBox(height: 32.h),

              // Keypad
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: _Keypad(
                    onDigit: _addDigit,
                    onDelete: _removeDigit,
                    primary: _primary,
                  ),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}

class _Keypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final Color primary;

  const _Keypad({
    required this.onDigit,
    required this.onDelete,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Expanded(
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: key.isEmpty
                    ? const SizedBox()
                    : _KeyButton(
                        label: key,
                        primary: primary,
                        onTap: key == 'del'
                            ? onDelete
                            : () => onDigit(key),
                        isDelete: key == 'del',
                      ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final Color primary;
  final VoidCallback onTap;
  final bool isDelete;

  const _KeyButton({
    required this.label,
    required this.primary,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete ? Colors.transparent : Colors.grey.shade100,
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace_outlined,
                  size: 22.sp, color: Colors.grey.shade600)
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}