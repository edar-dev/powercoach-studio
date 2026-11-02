import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../theme/stitch_m3_theme.dart';
import 'app_navigation.dart';
import 'app_paths.dart';

/// Wide-layout top chrome: global search without a new backend index.
///
/// Submitting navigates to Clienti with `?q=` so the list screen can seed its
/// local filter. Empty submit opens Clienti unfiltered.
class PrimaryShellTopChrome extends StatefulWidget {
  const PrimaryShellTopChrome({super.key});

  @override
  State<PrimaryShellTopChrome> createState() => _PrimaryShellTopChromeState();
}

class _PrimaryShellTopChromeState extends State<PrimaryShellTopChrome> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    HapticFeedback.selectionClick();
    final q = raw.trim();
    if (q.isEmpty) {
      navigateTo(context, AppPaths.customers);
      return;
    }
    navigateTo(
      context,
      Uri(
        path: AppPaths.customers,
        queryParameters: {'q': q},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Material(
      color: cs.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _submit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.shellGlobalSearchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: cs.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(StitchM3Theme.radiusLg),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(StitchM3Theme.radiusLg),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(StitchM3Theme.radiusLg),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),
          Container(height: 1, color: cs.outline),
        ],
      ),
    );
  }
}
