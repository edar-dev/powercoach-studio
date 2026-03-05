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

    if (_loading) {
      return Scaffold(
        backgroundColor: StitchM3Theme.bgSecondary,
        appBar: _editAppBar(context, theme, l10n.customerEdit),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: StitchM3Theme.bgSecondary,
        appBar: _editAppBar(context, theme, l10n.customerEdit),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadError!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: StitchM3Theme.danger,
                  ),
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
      backgroundColor: StitchM3Theme.bgSecondary,
      appBar: _editAppBar(context, theme, l10n.customerEdit),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.customerName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.customerNameRequired : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.customerEmail,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.customerPhone,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.customerHeight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.customerWeight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: l10n.customerNotes,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _goalsController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.customerGoals,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.customerSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _editAppBar(BuildContext context, ThemeData theme, String title) {
    return AppBar(
      backgroundColor: StitchM3Theme.bg,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black26,
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
          color: StitchM3Theme.textPrimary,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: StitchM3Theme.border, height: 1),
      ),
    );
  }
}
