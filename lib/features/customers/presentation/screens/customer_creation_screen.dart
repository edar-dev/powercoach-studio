import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../theme/stitch_m3_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_repository.dart';
import '../../data/models/customer.dart';

/// Customer Creation Page – Stitch screen ID 534f6e3664244ba59196220f2909eb46.
class CustomerCreationScreen extends StatefulWidget {
  const CustomerCreationScreen({super.key});

  @override
  State<CustomerCreationScreen> createState() => _CustomerCreationScreenState();
}

class _CustomerCreationScreenState extends State<CustomerCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _goalsController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool _saving = false;
  bool _prefillApplied = false;
  final CustomerRepository _repo = CustomerRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefillApplied) return;
    _prefillApplied = true;
    final q = GoRouterState.of(context).uri.queryParameters;
    if (q['name'] != null && q['name']!.isNotEmpty) {
      _nameController.text = q['name']!;
    }
    if (q['phone'] != null && q['phone']!.isNotEmpty) {
      _phoneController.text = q['phone']!;
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = SupabaseBootstrap.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    setState(() => _saving = true);
    final customer = Customer(
      id: '',
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
      final created = await _repo.create(customer);
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
      context.go('/customers/${created.id}');
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.customerSaveError,
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

  @override
  Widget build(BuildContext context) {
    final authLoading = authRouteLoadingOrNull();
    if (authLoading != null) return authLoading;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
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
          'Add New Client',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero: Stitch "Start a New Journey"
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(StitchM3Theme.radiusLg),
                    border: Border.all(color: StitchM3Theme.accent.withValues(alpha: 0.15)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        StitchM3Theme.accent.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: StitchM3Theme.accent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: StitchM3Theme.accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a New Journey',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Capture your client's initial details to begin tracking their progress.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _formLabel(context, l10n.customerName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.person, hint: 'e.g. Alex Johnson'),
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
                  decoration: _inputDecoration(context, prefixIcon: Icons.mail, hint: 'alex@example.com'),
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
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(context, prefixIcon: Icons.flag_outlined, hint: 'e.g. Muscle Gain'),
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
                const SizedBox(height: 16),
                Text(
                  'By adding a client, they will receive a welcome email automatically.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
