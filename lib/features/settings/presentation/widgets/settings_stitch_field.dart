import 'package:flutter/material.dart';

import '../../../../core/theme/marketing_dark_colors.dart';

/// Uppercase label + dark filled input matching Stitch settings HTML.
class SettingsStitchField extends StatelessWidget {
  const SettingsStitchField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.requiredMark = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.helper,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final bool requiredMark;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      borderSide: const BorderSide(color: MarketingDarkColors.stitchBorderMuted),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: MarketingDarkColors.slate300,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                  children: [
                    if (requiredMark)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: MarketingDarkColors.brandMid,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (helper != null)
              Text(
                helper!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.slate500,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: MarketingDarkColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: MarketingDarkColors.slate500,
            ),
            filled: true,
            fillColor: MarketingDarkColors.stitchInput,
            contentPadding: EdgeInsets.fromLTRB(
              16,
              maxLines > 1 ? 14 : 12,
              suffix == null ? 16 : 8,
              maxLines > 1 ? 14 : 12,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: MarketingDarkColors.brandMid,
                width: 1.5,
              ),
            ),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix,
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}
