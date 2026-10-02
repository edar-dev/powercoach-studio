import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/auth/supabase_bootstrap.dart';
import '../../../../core/pdf/pdf_brand_store.dart';
import '../../../../core/theme/marketing_dark_colors.dart';
import '../../../../core/theme/stitch_m3_theme.dart';
import '../../../../core/ui/widgets/stitch_secondary_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_unsaved_bar.dart';

/// Settings sub-page for PDF brand kit (studio name, accent, logo, disclaimer).
class PdfBrandSettingsScreen extends StatefulWidget {
  const PdfBrandSettingsScreen({super.key});

  @override
  State<PdfBrandSettingsScreen> createState() => _PdfBrandSettingsScreenState();
}

class _PdfBrandSettingsScreenState extends State<PdfBrandSettingsScreen> {
  static const _presetColors = <Color>[
    Color(0xFF0D59F2),
    Color(0xFF111827),
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFFBE123C),
    Color(0xFF7C3AED),
  ];

  final _studioNameController = TextEditingController();
  final _disclaimerController = TextEditingController();
  final _hexController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _dirty = false;
  bool _hidePowerCoachBranding = false;
  int? _accentColorArgb;
  Uint8List? _logoBytes;
  bool _logoRemoved = false;
  String? _pendingLogoExtension;
  Uint8List? _pendingLogoBytes;
  String? _loadError;

  String _savedStudioName = '';
  String _savedDisclaimer = '';
  bool _savedHideBranding = false;
  int? _savedAccentArgb;
  bool _savedHadLogo = false;

  @override
  void initState() {
    super.initState();
    _studioNameController.addListener(_onFieldChanged);
    _disclaimerController.addListener(_onFieldChanged);
    _hexController.addListener(_onHexChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  @override
  void dispose() {
    _studioNameController.removeListener(_onFieldChanged);
    _disclaimerController.removeListener(_onFieldChanged);
    _hexController.removeListener(_onHexChanged);
    _studioNameController.dispose();
    _disclaimerController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => _recomputeDirty();

  void _onHexChanged() {
    final parsed = _parseHex(_hexController.text);
    if (parsed != null && parsed != _accentColorArgb) {
      setState(() => _accentColorArgb = parsed);
    }
    _recomputeDirty();
  }

  void _recomputeDirty() {
    final logoDirty = _logoRemoved || _pendingLogoBytes != null;
    final dirty = _studioNameController.text != _savedStudioName ||
        _disclaimerController.text != _savedDisclaimer ||
        _hidePowerCoachBranding != _savedHideBranding ||
        _accentColorArgb != _savedAccentArgb ||
        logoDirty;
    if (mounted && dirty != _dirty) {
      setState(() => _dirty = dirty);
    } else if (!mounted) {
      _dirty = dirty;
    }
  }

  Future<void> _load() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = AppLocalizations.of(context).profileLoadError;
      });
      return;
    }
    try {
      final brand = await PdfBrandStore.instance.read(user.id);
      final logo = await PdfBrandStore.instance.loadLogoBytes(user.id);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = null;
        _applySaved(brand, logo);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  void _applySaved(PdfBrandData brand, Uint8List? logo) {
    _savedStudioName = brand.studioName;
    _savedDisclaimer = brand.disclaimer;
    _savedHideBranding = brand.hidePowerCoachBranding;
    _savedAccentArgb = brand.accentColorArgb;
    _savedHadLogo = logo != null && logo.isNotEmpty;
    _studioNameController.text = brand.studioName;
    _disclaimerController.text = brand.disclaimer;
    _hidePowerCoachBranding = brand.hidePowerCoachBranding;
    _accentColorArgb = brand.accentColorArgb;
    _hexController.text = brand.accentColorArgb == null
        ? ''
        : _argbToHex(brand.accentColorArgb!);
    _logoBytes = logo;
    _logoRemoved = false;
    _pendingLogoBytes = null;
    _pendingLogoExtension = null;
    _dirty = false;
  }

  void _cancelChanges() {
    setState(() {
      _studioNameController.text = _savedStudioName;
      _disclaimerController.text = _savedDisclaimer;
      _hidePowerCoachBranding = _savedHideBranding;
      _accentColorArgb = _savedAccentArgb;
      _hexController.text =
          _savedAccentArgb == null ? '' : _argbToHex(_savedAccentArgb!);
      _logoRemoved = false;
      _pendingLogoBytes = null;
      _pendingLogoExtension = null;
      _dirty = false;
    });
  }

  Future<void> _pickLogo() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pdfBrandLogoPickError)),
      );
      return;
    }
    if (bytes.length > PdfBrandStore.maxLogoBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pdfBrandLogoTooLarge)),
      );
      return;
    }
    final ext = (file.extension ?? 'png').toLowerCase();
    setState(() {
      _pendingLogoBytes = bytes;
      _pendingLogoExtension = ext;
      _logoRemoved = false;
      _logoBytes = bytes;
    });
    _recomputeDirty();
  }

  void _removeLogo() {
    setState(() {
      _logoRemoved = true;
      _pendingLogoBytes = null;
      _pendingLogoExtension = null;
      _logoBytes = null;
    });
    _recomputeDirty();
  }

  Future<void> _save() async {
    final user = SupabaseBootstrap.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    setState(() => _isSaving = true);
    try {
      var brand = PdfBrandData(
        studioName: _studioNameController.text.trim(),
        accentColorArgb: _accentColorArgb,
        disclaimer: _disclaimerController.text.trim(),
        hidePowerCoachBranding: _hidePowerCoachBranding,
        logoRelativePath: _logoRemoved
            ? null
            : (await PdfBrandStore.instance.read(user.id)).logoRelativePath,
      );
      await PdfBrandStore.instance.write(user.id, brand);

      if (_logoRemoved && _savedHadLogo) {
        brand = await PdfBrandStore.instance.clearLogo(user.id);
      } else if (_pendingLogoBytes != null) {
        brand = await PdfBrandStore.instance.saveLogo(
          user.id,
          _pendingLogoBytes!,
          extension: _pendingLogoExtension ?? 'png',
        );
      }

      final logo = await PdfBrandStore.instance.loadLogoBytes(user.id);
      if (!mounted) return;
      setState(() => _applySaved(brand, logo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfBrandSavedMessage),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PdfBrandLogoTooLargeException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfBrandLogoTooLarge),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfBrandSaveError),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = SupabaseBootstrap.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.stitchPageBg,
        appBar: StitchSecondaryAppBar(title: l10n.pdfBrandSettingsTitle),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null && user == null) {
      return Scaffold(
        backgroundColor: MarketingDarkColors.stitchPageBg,
        appBar: StitchSecondaryAppBar(title: l10n.pdfBrandSettingsTitle),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.profileLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: MarketingDarkColors.slate400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.headerLogin),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final previewColor = _accentColorArgb == null
        ? StitchM3Theme.accent
        : Color(_accentColorArgb!);

    return Scaffold(
      backgroundColor: MarketingDarkColors.stitchPageBg,
      appBar: StitchSecondaryAppBar(title: l10n.pdfBrandSettingsTitle),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 24, 24, _dirty ? 100 : 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.pdfBrandSettingsSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MarketingDarkColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.pdfBrandStudioNameLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MarketingDarkColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _studioNameController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        hint: l10n.pdfBrandStudioNameHint,
                      ),
                      style: const TextStyle(color: MarketingDarkColors.text),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.pdfBrandAccentLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MarketingDarkColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final color in _presetColors)
                          _ColorChip(
                            color: color,
                            selected: _accentColorArgb == color.toARGB32(),
                            onTap: () {
                              setState(() {
                                _accentColorArgb = color.toARGB32();
                                _hexController.text = _argbToHex(color.toARGB32());
                              });
                              _recomputeDirty();
                            },
                          ),
                        _ColorChip(
                          color: StitchM3Theme.accent,
                          selected: _accentColorArgb == null,
                          label: l10n.pdfBrandAccentDefault,
                          onTap: () {
                            setState(() {
                              _accentColorArgb = null;
                              _hexController.text = '';
                            });
                            _recomputeDirty();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hexController,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-fA-F#]'),
                        ),
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: _decoration(
                        hint: l10n.pdfBrandAccentHexHint,
                        prefix: Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: previewColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: MarketingDarkColors.stitchBorderMuted,
                            ),
                          ),
                        ),
                      ),
                      style: const TextStyle(color: MarketingDarkColors.text),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.pdfBrandDisclaimerLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MarketingDarkColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _disclaimerController,
                      maxLines: 3,
                      decoration: _decoration(
                        hint: l10n.pdfBrandDisclaimerHint,
                      ),
                      style: const TextStyle(color: MarketingDarkColors.text),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _hidePowerCoachBranding,
                      onChanged: (v) {
                        setState(() => _hidePowerCoachBranding = v);
                        _recomputeDirty();
                      },
                      title: Text(
                        l10n.pdfBrandWhiteLabelLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: MarketingDarkColors.text,
                        ),
                      ),
                      subtitle: Text(
                        l10n.pdfBrandWhiteLabelSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MarketingDarkColors.slate400,
                        ),
                      ),
                      activeThumbColor: MarketingDarkColors.brand,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.pdfBrandLogoLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MarketingDarkColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.pdfBrandLogoLocalHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MarketingDarkColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_logoBytes != null && !_logoRemoved)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _logoBytes!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: Text(
                            _logoBytes == null || _logoRemoved
                                ? l10n.pdfBrandLogoPick
                                : l10n.pdfBrandLogoReplace,
                          ),
                        ),
                        if ((_logoBytes != null && !_logoRemoved) ||
                            _savedHadLogo)
                          TextButton(
                            onPressed: _removeLogo,
                            child: Text(l10n.pdfBrandLogoRemove),
                          ),
                      ],
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _loadError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_dirty)
            Align(
              alignment: Alignment.bottomCenter,
              child: SettingsUnsavedBar(
                saving: _isSaving,
                onCancel: _cancelChanges,
                onSave: _save,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _decoration({required String hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: MarketingDarkColors.slate500),
      filled: true,
      fillColor: MarketingDarkColors.stitchCard,
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: prefix,
            ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MarketingDarkColors.stitchBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: MarketingDarkColors.stitchBorderMuted,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MarketingDarkColors.brand),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  static int? _parseHex(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) {
      final value = int.tryParse(s, radix: 16);
      if (value == null) return null;
      return 0xFF000000 | value;
    }
    if (s.length == 8) {
      return int.tryParse(s, radix: 16);
    }
    return null;
  }

  static String _argbToHex(int argb) {
    final rgb = argb & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.selected,
    required this.onTap,
    this.label,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label == null ? 4 : 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? MarketingDarkColors.brandLight
                : MarketingDarkColors.stitchBorderMuted,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: MarketingDarkColors.slate300,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
