import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_mobile_colors.dart';

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
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.helper,
    this.focusNode,
    this.mobileStyle = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final bool requiredMark;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final String? helper;
  final FocusNode? focusNode;
  final bool mobileStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = mobileStyle
        ? StitchMobileColors.onSurfaceVariant
        : MarketingDarkColors.slate300;
    final fill = mobileStyle
        ? StitchMobileColors.surfaceContainerLow
        : MarketingDarkColors.stitchInput;
    final textColor =
        mobileStyle ? StitchMobileColors.onSurface : MarketingDarkColors.text;
    final radius = mobileStyle
        ? StitchMobileColors.radiusLg
        : MarketingDarkColors.radiusXl;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: mobileStyle
            ? Colors.transparent
            : MarketingDarkColors.stitchBorderMuted,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: mobileStyle ? label : label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: mobileStyle ? 0 : 0.8,
                    fontSize: mobileStyle ? 11 : null,
                  ),
                  children: [
                    if (requiredMark && !mobileStyle)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: MarketingDarkColors.brandMid,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (helper != null && mobileStyle)
                      TextSpan(
                        text: ' $helper',
                        style: const TextStyle(
                          color: StitchMobileColors.tertiary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (helper != null && !mobileStyle)
              Text(
                helper!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: MarketingDarkColors.slate500,
                  fontSize: 11,
                ),
              ),
            if (suffix != null && !mobileStyle) suffix!,
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: maxLength == null
              ? null
              : [LengthLimitingTextInputFormatter(maxLength)],
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: mobileStyle
                  ? StitchMobileColors.outline
                  : MarketingDarkColors.slate500,
            ),
            filled: true,
            fillColor: fill,
            counterStyle: mobileStyle
                ? theme.textTheme.labelSmall?.copyWith(
                    color: StitchMobileColors.onSurfaceVariant,
                    fontSize: 11,
                  )
                : null,
            contentPadding: EdgeInsets.fromLTRB(
              mobileStyle ? 14 : 16,
              maxLines > 1 ? 14 : (mobileStyle ? 14 : 12),
              suffix == null ? (mobileStyle ? 14 : 16) : 8,
              maxLines > 1 ? 14 : (mobileStyle ? 14 : 12),
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: mobileStyle
                    ? StitchMobileColors.primaryContainer
                    : MarketingDarkColors.brandMid,
                width: 1.5,
              ),
            ),
            suffixIcon: suffix == null || mobileStyle
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
