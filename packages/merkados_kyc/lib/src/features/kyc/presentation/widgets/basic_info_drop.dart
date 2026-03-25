import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BasicInfoDrop extends StatelessWidget {
  const BasicInfoDrop({
    super.key,
    required this.formKey,
    required this.caption,
    required this.initial,
    this.isReadOnly = false,
    this.onSelect,
    this.checkValid,
  });

  final GlobalKey<FormState> formKey;
  final String caption;
  final String? initial;
  final bool isReadOnly;
  final void Function(String?)? onSelect;
  final String? Function(String?)? checkValid;

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
            // top: 12,
            left: 14,
            right: 14,
            // bottom: 10,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F4F1),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: const Color(0xFFCCCAC2)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: initial,
            decoration: const InputDecoration(
              hintText: 'Select a provider',
              border: InputBorder.none,
            ),
            items: [
              'AEDC',
              'BEDC',
              'EKEDC',
              'EEDC',
              'IBEDC',
              'IKEDC',
              'JEDC',
              'KAEDCO',
              'KEDCO',
              'PHEDC',
              'YEDC',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => onSelect?.call(v),
            validator: (v) => checkValid?.call(v),
          ),
        ),
      ],
    );
  }
}
