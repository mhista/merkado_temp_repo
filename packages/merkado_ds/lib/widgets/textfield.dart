import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TextFieldForm extends StatefulWidget {
  const TextFieldForm({
    super.key,
    required this.controller,
    required this.fieldName,
    this.validator,
    this.labelText,
    this.hintText,
    this.icon,
    this.obscureText = false,
    this.expands = false,
    this.suffixIcon,
    this.useSuffixIcon = false,
    this.minLines,
    this.maxLines = 1,
    this.decoration,
    this.canDispose = true,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String fieldName;
  final String? Function(String?)? validator;
  final String? labelText, hintText;
  final List<List<dynamic>>? icon;
  final List<List<dynamic>>? suffixIcon;
  final int? minLines, maxLines;
  final bool obscureText;
  final bool expands, useSuffixIcon, enabled;
  final InputDecoration? decoration;
  final bool? canDispose;
  @override
  State<TextFieldForm> createState() => _TextFieldFormState();
}

class _TextFieldFormState extends State<TextFieldForm> {
  bool? shouldShow;
  @override
  void initState() {
    shouldShow = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enableInteractiveSelection: true,
      obscureText: shouldShow ?? false,
      controller: widget.controller,
      validator: widget.validator,
      expands: widget.expands,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      decoration:
          widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            // hintStyle: Theme.of(context).textTheme.titleMedium!.apply(
            //   fontWeightDelta: -1,
            //   color: PColors.accent.withValues(alpha: 0.9),
            // ),
            prefixIcon: widget.icon != null ? HugeIcon(icon: widget.icon!) : null,
            suffixIcon: widget.useSuffixIcon
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        if (widget.obscureText == true) {
                          shouldShow = !shouldShow!;
                        }
                      });
                    },
                    icon: widget.obscureText
                        ? HugeIcon(
                            icon: (shouldShow ?? false)
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedViewOff,
                          )
                        : widget.suffixIcon != null
                        ? HugeIcon(icon: widget.suffixIcon!)
                        : const SizedBox(),
                  )
                : null,
            alignLabelWithHint: true,
          ),
    );
  }

  @override
  void dispose() {
    debugPrint('disposing ${widget.controller.text}');
    if (widget.canDispose == true) {
      widget.controller.clear();
      widget.controller.dispose();
    }
    super.dispose();
  }
}
