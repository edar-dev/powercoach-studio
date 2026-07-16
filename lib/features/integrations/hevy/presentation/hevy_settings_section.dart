import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'package:powercoach_studio/core/billing/plan_gate.dart';
import 'package:powercoach_studio/core/ui/widgets/app_snackbar.dart';
import '../data/hevy_api_client.dart';
import '../data/hevy_api_models.dart';
import '../data/hevy_catalog_import_service.dart';
import '../data/hevy_settings_store.dart';

/// Hevy API key + sync controls for [SettingsScreen].
class HevySettingsSection extends StatefulWidget {
  const HevySettingsSection({super.key});

  @override
  State<HevySettingsSection> createState() => _HevySettingsSectionState();
}

class _HevySettingsSectionState extends State<HevySettingsSection> {
  final _keyController = TextEditingController();
  bool _loading = true;
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await HevySettingsStore.instance.getApiKey();
    if (!mounted) return;
    setState(() {
      _keyController.text = key ?? '';
      _loading = false;
    });
  }

  Future<void> _saveKey() async {
    if (!await PlanGate.requirePro(context, feature: PaywallFeature.hevy)) {
      return;
    }
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await HevySettingsStore.instance.setApiKey(_keyController.text);
      if (!mounted) return;
      setState(() => _status = l10n.hevySettingsKeySaved);
      showAppSnackBar(context, content: Text(l10n.hevySettingsKeySaved));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await HevyApiClient().testConnection();
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevySettingsTestSuccess));
    } on HevyApiException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevySettingsTestFailed(e.message)));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevySettingsTestFailed(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncCatalog() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = l10n.hevyImportInProgress;
    });
    try {
      final count = await HevyCatalogImportService().importAllFromApi(
        onProgress: (current, total, label) {
          if (mounted) {
            setState(() => _status = '$label ($current/$total)');
          }
        },
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        content: Text(l10n.hevyImportSuccessCount(count)),
      );
    } on HevyApiException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevyImportFailed(e.message)));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, content: Text(l10n.hevyImportFailed(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.hevySettingsSectionTitle,
          style: theme.textTheme.titleSmall?.copyWith(color: cs.primary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.hevySettingsSectionSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _keyController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.hevySettingsApiKeyLabel,
            hintText: l10n.hevySettingsApiKeyHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: _busy ? null : _saveKey,
              child: Text(l10n.hevySettingsSaveKey),
            ),
            OutlinedButton(
              onPressed: _busy ? null : _testConnection,
              child: Text(l10n.hevySettingsTestConnection),
            ),
            OutlinedButton(
              onPressed: _busy ? null : _syncCatalog,
              child: Text(l10n.hevySettingsSyncCatalog),
            ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(
            _status!,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
