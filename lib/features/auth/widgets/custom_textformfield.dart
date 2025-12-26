import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.hintStyle,
    super.key,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.onSuffixTap,
  });

  final String labelText;
  final TextEditingController controller;

  final bool obscureText;
  final bool isPassword;
  final bool readOnly;
  final int maxLines;
  final bool enabled;

  final TextStyle? hintStyle;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      onTap: widget.onTap,
      autovalidateMode: widget.autovalidateMode,
      cursorColor: AppColors.primaryColor,
      enabled: widget.enabled,
      style: AppThemes.f16w400,
      obscureText: widget.isPassword ? _obscure : false,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFEFEFEF),
        hintText: widget.labelText,
        hintStyle: widget.hintStyle ??
            AppThemes.f14w400.copyWith(
              color: Colors.black.withOpacity(0.3),
            ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _errorBorder(),
        helperText: '',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      ),
    );
  }

  OutlineInputBorder _border() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFEFEFEF)),
    );
  }

  OutlineInputBorder _errorBorder() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Colors.red),
    );
  }

  Widget? _buildSuffixIcon() {
    /// Priority 1: Custom suffix icon
    if (widget.suffixIcon != null) {
      return InkWell(
        onTap: widget.onSuffixTap,
        child: widget.suffixIcon,
      );
    }

    /// Priority 2: Password toggle
    if (widget.isPassword) {
      return IconButton(
        splashRadius: 20,
        icon: Icon(
          _obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.black.withOpacity(0.4),
        ),
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      );
    }

    return null;
  }
}
