import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class BasicInfoInput extends StatelessWidget {
  const BasicInfoInput({
    super.key,
    required this.formKey,
    required this.caption,
    required this.controller,
    this.isReadOnly = false,
    required this.textHint,
    this.onDateSelect,
    this.helperText,
    this.checkValid,
    this.inputType = TextInputType.number,
    this.digits = 11,
  });

  final GlobalKey<FormState> formKey;
  final String caption;
  final TextEditingController controller;
  final bool isReadOnly;
  final String textHint;
  final void Function(DateTime)? onDateSelect;
  final String? helperText;
  final String? Function(String?)? checkValid;
  final TextInputType inputType;
  final int digits;

  @override
  Widget build(BuildContext context) {
    final double devWidth = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            caption,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: devWidth,
          height: 43.0,
          padding: const EdgeInsets.only(
            top: 12,
            left: 14,
            right: 14,
            bottom: 10,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F4F1),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: const Color(0xFFCCCAC2)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly,
            keyboardType: inputType,
            inputFormatters: inputType == TextInputType.number
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(digits),
                  ]
                : [],
            onTap: isReadOnly
                ? () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 6570),
                      ),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.text = DateFormat('dd-MM-yyyy').format(date);
                      formKey.currentState?.validate();
                      onDateSelect?.call(date);
                    }
                  }
                : null,
            decoration: InputDecoration(
              hintText: textHint,
              suffixIcon: isReadOnly
                  ? Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    )
                  : null,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            validator: (v) => checkValid?.call(v),
          ),
        ),
        (helperText != null)
            ? const SizedBox(height: AppSpacing.sm)
            : const SizedBox.shrink(),
        if (helperText != null)
          Text(
            helperText!,
            style: TextStyle(
              color: const Color(0xFF9A9A9A),
              fontSize: 11.50,
              fontFamily: 'Instrument Sans',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
      ],
    );
  }
}
