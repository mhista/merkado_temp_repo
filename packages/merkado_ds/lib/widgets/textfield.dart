import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
  final IconData? icon;
  final IconData? suffixIcon;
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
      style: Theme.of(
        context,
      ).textTheme.titleMedium!.apply(fontWeightDelta: -1, color: Colors.black),
      decoration:
          widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.titleMedium!.apply(
              fontWeightDelta: -1,
              color: Colors.black, //PColors.accent.withValues(alpha: 0.9),
            ),
            labelStyle: Theme.of(context).textTheme.titleMedium!.apply(
              fontWeightDelta: -1,
              color: Colors.black, //PColors.accent.withValues(alpha: 0.9),
            ),
            floatingLabelStyle: Theme.of(context).textTheme.titleMedium!.apply(
              fontWeightDelta: -1,
              color: Colors.black, //PColors.accent.withValues(alpha: 0.9),
            ),

            prefixIcon: widget.icon != null ? Icon(widget.icon!) : null,
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
                        ? Icon(
                            color: Theme.of(context).iconTheme.color,
                            (shouldShow ?? false)
                                ? Iconsax.eye
                                : Iconsax.eye_slash,
                          )
                        : widget.suffixIcon != null
                        ? Icon(widget.suffixIcon!)
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
