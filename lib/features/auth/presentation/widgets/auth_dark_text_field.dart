import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';

/// Uppercase label + icon + dark rounded field matching Stitch auth HTML.
class AuthDarkTextField extends StatelessWidget {
  const AuthDarkTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: MarketingDarkColors.slate300,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          style: const TextStyle(
            color: MarketingDarkColors.text,
            fontSize: 14,
          ),
          cursorColor: MarketingDarkColors.brandLight,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: MarketingDarkColors.slate500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: MarketingDarkColors.surface900.withValues(alpha: 0.9),
            contentPadding: EdgeInsets.only(
              left: prefixIcon != null ? 4 : 14,
              right: onToggleObscure != null ? 4 : 14,
              top: 14,
              bottom: 14,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: 18,
                    color: MarketingDarkColors.slate500,
                  ),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: MarketingDarkColors.slate400,
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              borderSide: BorderSide(
                color: MarketingDarkColors.borderMuted.withValues(alpha: 0.8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              borderSide: BorderSide(
                color: MarketingDarkColors.borderMuted.withValues(alpha: 0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              borderSide: const BorderSide(
                color: MarketingDarkColors.brandMid,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              ),
            ),
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
