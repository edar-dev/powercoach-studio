import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../core/network/gymblog_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer.dart';

/// Edit customer – same form as creation, prefilled and PUT on save.
class CustomerEditScreen extends StatefulWidget {
  const CustomerEditScreen({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _goalsController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final GymBlogApiClient _api = GymBlogApiClient();
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _goalsController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final data = await _api.get('/api/customers/${widget.customerId}');
      final c = Customer.fromJson(data);
      if (mounted) {
        _nameController.text = c.name;
        _emailController.text = c.email ?? '';
        _phoneController.text = c.phone ?? '';
        _notesController.text = c.notes ?? '';
        _goalsController.text = c.goals ?? '';
        _heightController.text = c.heightCm != null ? c.heightCm!.round().toString() : '';
        _weightController.text = c.weightKg != null ? c.weightKg.toString() : '';
        setState(() {
          _loading = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e is GymBlogApiException ? e.message : e.toString();
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    setState(() => _saving = true);
    final customer = Customer(
      id: widget.customerId,
      userId: user.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: null,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      goals: _goalsController.text.trim().isEmpty ? null : _goalsController.text.trim(),
      pdfHeader: null,
      useCustomPdfHeader: false,
      isFavorite: false,
      isArchived: false,
      lastPlanUpdateDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _api.put('/api/customers/${widget.customerId}', customer.toUpdateBody());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.profileSavedMessage,
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          backgroundColor: colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/customers/${widget.customerId}');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is GymBlogApiException ? e.message : l10n.customerSaveError,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: _editAppBar(context, theme, colorScheme, l10n.customerEdit),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: _editAppBar(context, theme, colorScheme, l10n.customerEdit),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _loadError!,
                  style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.customerCancel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _editAppBar(context, theme, colorScheme, l10n.customerEdit),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _formLabel(context, l10n.customerName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.person, hint: l10n.customerName),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.customerNameRequired : null,
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerEmail),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.mail, hint: 'email@example.com'),
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerPhone),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.phone_outlined),
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerGoals),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _goalsController,
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.flag_outlined, hint: l10n.customerGoals),
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerWeight),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.monitor_weight_outlined, hint: '0.0'),
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerHeight),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.height),
                ),
                const SizedBox(height: 24),
                _formLabel(context, l10n.customerNotes),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.customerNotes,
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: StitchM3Theme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(0, 48),
                    elevation: 4,
                    shadowColor: StitchM3Theme.accent.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.customerSave),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {required IconData prefixIcon, String? hint}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      prefixIcon: Icon(prefixIcon, size: 22, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StitchM3Theme.radiusMd),
        borderSide: BorderSide(color: cs.outline),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  PreferredSizeWidget _editAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme, String title) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.pop();
        },
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: colorScheme.outline, height: 1),
      ),
    );
  }
}
