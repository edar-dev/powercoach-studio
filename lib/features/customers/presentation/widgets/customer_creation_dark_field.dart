import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';

InputDecoration customerCreationInputDecoration({
  String? hint,
  IconData? prefixIcon,
  String? suffixText,
  Widget? prefix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: MarketingDarkColors.slate500,
      fontSize: 14,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: MarketingDarkColors.slate400),
    prefix: prefix,
    suffixText: suffixText,
    suffixStyle: const TextStyle(
      color: MarketingDarkColors.slate400,
      fontSize: 12,
    ),
    filled: true,
    fillColor: MarketingDarkColors.surfaceInput,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      borderSide: const BorderSide(color: MarketingDarkColors.borderSubtle),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      borderSide: const BorderSide(color: MarketingDarkColors.borderSubtle),
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
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
  );
}

class CustomerCreationSectionTitle extends StatelessWidget {
  const CustomerCreationSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MarketingDarkColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MarketingDarkColors.brand,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: MarketingDarkColors.slate300,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerCreationDarkField extends StatelessWidget {
  const CustomerCreationDarkField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MarketingDarkColors.slate300,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            color: MarketingDarkColors.text,
            fontSize: 14,
          ),
          cursorColor: MarketingDarkColors.brandLight,
          validator: validator,
          decoration: customerCreationInputDecoration(
            hint: hint,
            prefixIcon: prefixIcon,
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }
}

class CustomerCreationPhoneField extends StatelessWidget {
  const CustomerCreationPhoneField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.prefixLabel,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String prefixLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MarketingDarkColors.slate300,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: MarketingDarkColors.surface700.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(MarketingDarkColors.radiusXl),
                ),
                border: Border.all(color: MarketingDarkColors.borderSubtle),
              ),
              child: Text(
                prefixLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  color: MarketingDarkColors.text,
                  fontSize: 14,
                ),
                cursorColor: MarketingDarkColors.brandLight,
                decoration: customerCreationInputDecoration(
                  hint: hint,
                  prefixIcon: Icons.phone_outlined,
                ).copyWith(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(MarketingDarkColors.radiusXl),
                    ),
                    borderSide: BorderSide(
                      color: MarketingDarkColors.borderSubtle,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(MarketingDarkColors.radiusXl),
                    ),
                    borderSide: BorderSide(
                      color: MarketingDarkColors.borderSubtle,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(MarketingDarkColors.radiusXl),
                    ),
                    borderSide: BorderSide(
                      color: MarketingDarkColors.brandMid,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomerCreationTapField extends StatelessWidget {
  const CustomerCreationTapField({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.hint,
    this.prefixIcon,
  });

  final String label;
  final VoidCallback onTap;
  final String? value;
  final String? hint;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final display = value ?? hint ?? '';
    final isHint = value == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MarketingDarkColors.slate300,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            child: InputDecorator(
              decoration: customerCreationInputDecoration(
                prefixIcon: prefixIcon,
              ),
              child: Text(
                display,
                style: TextStyle(
                  color: isHint
                      ? MarketingDarkColors.slate500
                      : MarketingDarkColors.text,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerCreationReadonlyField extends StatelessWidget {
  const CustomerCreationReadonlyField({
    super.key,
    required this.label,
    this.value,
    this.hint,
    this.suffix,
  });

  final String label;
  final String? value;
  final String? hint;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: MarketingDarkColors.slate300,
          ),
        ),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: customerCreationInputDecoration(suffixText: suffix),
          child: Text(
            value ?? hint ?? '—',
            style: TextStyle(
              color: value == null
                  ? MarketingDarkColors.slate500
                  : MarketingDarkColors.text,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
