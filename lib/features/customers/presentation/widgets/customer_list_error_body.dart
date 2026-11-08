import 'package:flutter/material.dart';

import 'package:powercoach_studio/core/ui/widgets/inline_error_banner.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerListErrorBody extends StatelessWidget {
  const CustomerListErrorBody({
    super.key,
    required this.l10n,
    required this.error,
    required this.onRetry,
  });

  final AppLocalizations l10n;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: InlineErrorBanner(
            message: l10n.customersLoadError,
            detail: error,
            onRetry: onRetry,
            retryLabel: l10n.customersRetry,
          ),
        ),
      ),
    );
  }
}
