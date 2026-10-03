import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:powercoach_studio/core/auth/supabase_bootstrap.dart';
import 'package:powercoach_studio/core/billing/plan_gate.dart';
import 'package:powercoach_studio/core/routing/auth_route_loading.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/remote/cloud_save_error_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/customer_repository.dart';
import '../../data/models/customer.dart';
import '../widgets/customer_creation_dark_field.dart';
import '../widgets/customer_creation_goal_chips.dart';
import '../widgets/customer_creation_hero_banner.dart';

/// New customer – Stitch dark form (`new-customer-dark`, screen 9cdeb5f6…).
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
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _pdfHeaderController = TextEditingController();
  bool _saving = false;
  bool _prefillApplied = false;
  bool _useCustomPdfHeader = false;
  DateTime? _dateOfBirth;
  int? _selectedGoalIndex;
  int _experienceIndex = 1; // intermediate default (Stitch)
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
    _heightController.dispose();
    _weightController.dispose();
    _pdfHeaderController.dispose();
    super.dispose();
  }

  int? get _estimatedAge {
    final dob = _dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    final m = now.month - dob.month;
    if (m < 0 || (m == 0 && now.day < dob.day)) age--;
    if (age <= 0 || age >= 110) return null;
    return age;
  }

  String _experienceLabel(AppLocalizations l10n) {
    return switch (_experienceIndex) {
      0 => l10n.customerExperienceBeginner,
      1 => l10n.customerExperienceIntermediate,
      2 => l10n.customerExperienceAdvanced,
      _ => l10n.customerExperienceElite,
    };
  }

  String? _composeNotes(AppLocalizations l10n) {
    final coachNotes = _notesController.text.trim();
    final experienceLine =
        l10n.customerExperienceNotesPrefix(_experienceLabel(l10n));
    if (coachNotes.isEmpty) return experienceLine;
    return '$experienceLine\n\n$coachNotes';
  }

  String? _composeGoals(AppLocalizations l10n) {
    if (_selectedGoalIndex == null) return null;
    final labels = [
      l10n.customerGoalHypertrophy,
      l10n.customerGoalStrength,
      l10n.customerGoalRecomp,
      l10n.customerGoalAthletic,
    ];
    return labels[_selectedGoalIndex!];
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 28, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MarketingDarkColors.brand,
              surface: MarketingDarkColors.surface,
              onSurface: MarketingDarkColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
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
    try {
      final existing = await _repo.getAll();
      final activeCount = existing.where((c) => !c.isArchived).length;
      if (!await PlanGate.canAddCustomer(activeCount)) {
        if (!mounted) return;
        setState(() => _saving = false);
        await PlanGate.requirePro(
          context,
          feature: PaywallFeature.customers,
          activeCustomerCount: activeCount,
        );
        return;
      }

      final dob = _dateOfBirth;
      final dobIso = dob == null
          ? null
          : '${dob.year.toString().padLeft(4, '0')}-'
              '${dob.month.toString().padLeft(2, '0')}-'
              '${dob.day.toString().padLeft(2, '0')}';

      final customer = Customer(
        id: '',
        userId: user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        dateOfBirth: dobIso,
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        notes: _composeNotes(l10n),
        goals: _composeGoals(l10n),
        pdfHeader: _useCustomPdfHeader
            ? (_pdfHeaderController.text.trim().isEmpty
                ? null
                : _pdfHeaderController.text.trim())
            : null,
        useCustomPdfHeader: _useCustomPdfHeader &&
            _pdfHeaderController.text.trim().isNotEmpty,
        isFavorite: false,
        isArchived: false,
        lastPlanUpdateDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

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
            tryCloudSaveErrorMessage(e, l10n) ?? l10n.customerSaveError,
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
    final authLoading = authRouteLoadingOrNull();
    if (authLoading != null) return authLoading;

    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: MarketingDarkColors.bgAlt,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CreationHeader(
              l10n: l10n,
              onBack: () {
                HapticFeedback.mediumImpact();
                context.pop();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CustomerCreationHeroBanner(),
                        const SizedBox(height: 28),
                        CustomerCreationSectionTitle(
                          title: l10n.customerCreationSectionAnagrafica,
                        ),
                        const SizedBox(height: 14),
                        CustomerCreationDarkField(
                          label: '${l10n.customerName} *',
                          controller: _nameController,
                          hint: l10n.customerNameHint,
                          prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? l10n.customerNameRequired
                              : null,
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final sideBySide = constraints.maxWidth >= 520;
                            final email = CustomerCreationDarkField(
                              label: l10n.customerEmail,
                              controller: _emailController,
                              hint: l10n.customerEmailHint,
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            );
                            final phone = CustomerCreationPhoneField(
                              label: l10n.customerPhone,
                              controller: _phoneController,
                              hint: l10n.customerPhoneHint,
                              prefixLabel: l10n.customerPhoneCountryPrefix,
                            );
                            if (!sideBySide) {
                              return Column(
                                children: [
                                  email,
                                  const SizedBox(height: 14),
                                  phone,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: email),
                                const SizedBox(width: 12),
                                Expanded(child: phone),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        CustomerCreationSectionTitle(
                          title: l10n.customerCreationSectionPhysical,
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth >= 640
                                ? 4
                                : constraints.maxWidth >= 400
                                    ? 2
                                    : 1;
                            final age = _estimatedAge;
                            final items = [
                              CustomerCreationTapField(
                                label: l10n.customerDateOfBirth,
                                value: _dateOfBirth == null
                                    ? null
                                    : MaterialLocalizations.of(context)
                                        .formatCompactDate(_dateOfBirth!),
                                hint: l10n.customerDateOfBirth,
                                prefixIcon: Icons.calendar_today_outlined,
                                onTap: _pickDateOfBirth,
                              ),
                              CustomerCreationReadonlyField(
                                label: l10n.customerEstimatedAge,
                                value: age?.toString(),
                                hint: '—',
                                suffix: l10n.customerEstimatedAgeUnit,
                              ),
                              CustomerCreationDarkField(
                                label: l10n.customerHeight,
                                controller: _heightController,
                                hint: l10n.customerHeightHint,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                suffixText: l10n.customerHeightUnit,
                              ),
                              CustomerCreationDarkField(
                                label: l10n.customerWeight,
                                controller: _weightController,
                                hint: l10n.customerWeightHint,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                suffixText: l10n.customerWeightUnit,
                              ),
                            ];
                            if (cols == 1) {
                              return Column(
                                children: [
                                  for (var i = 0; i < items.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 12),
                                    items[i],
                                  ],
                                ],
                              );
                            }
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final item in items)
                                  SizedBox(
                                    width: cols == 4
                                        ? (constraints.maxWidth - 36) / 4
                                        : (constraints.maxWidth - 12) / 2,
                                    child: item,
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        CustomerCreationSectionTitle(
                          title: l10n.customerCreationSectionGoals,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.customerGoals,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MarketingDarkColors.slate300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomerCreationGoalChips(
                          selectedIndex: _selectedGoalIndex,
                          onSelected: (i) =>
                              setState(() => _selectedGoalIndex = i),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.customerExperienceLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MarketingDarkColors.slate300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _experienceIndex,
                          dropdownColor: MarketingDarkColors.surface800,
                          style: const TextStyle(
                            color: MarketingDarkColors.text,
                            fontSize: 14,
                          ),
                          decoration: customerCreationInputDecoration(),
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(l10n.customerExperienceBeginner),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(l10n.customerExperienceIntermediate),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(l10n.customerExperienceAdvanced),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text(l10n.customerExperienceElite),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _experienceIndex = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.customerNotes,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: MarketingDarkColors.slate300,
                                ),
                              ),
                            ),
                            Text(
                              l10n.customerNotesOptional,
                              style: const TextStyle(
                                fontSize: 11,
                                color: MarketingDarkColors.slate500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: MarketingDarkColors.text,
                            fontSize: 14,
                          ),
                          cursorColor: MarketingDarkColors.brandLight,
                          decoration: customerCreationInputDecoration(
                            hint: l10n.customerNotesHintCreation,
                          ),
                        ),
                        const SizedBox(height: 28),
                        CustomerCreationSectionTitle(
                          title: l10n.customerPdfHeaderSection,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _useCustomPdfHeader,
                          onChanged: (v) =>
                              setState(() => _useCustomPdfHeader = v),
                          title: Text(
                            l10n.customerUseCustomPdfHeader,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: MarketingDarkColors.slate300,
                            ),
                          ),
                          subtitle: Text(
                            l10n.customerUseCustomPdfHeaderSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MarketingDarkColors.slate500,
                            ),
                          ),
                          activeThumbColor: MarketingDarkColors.brand,
                        ),
                        if (_useCustomPdfHeader) ...[
                          const SizedBox(height: 8),
                          CustomerCreationDarkField(
                            label: l10n.customerPdfHeaderLabel,
                            controller: _pdfHeaderController,
                            hint: l10n.customerPdfHeaderHint,
                            prefixIcon: Icons.badge_outlined,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _CreationFooter(
              l10n: l10n,
              saving: _saving,
              bottomInset: bottomInset,
              onCancel: () => context.pop(),
              onSave: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreationHeader extends StatelessWidget {
  const _CreationHeader({required this.l10n, required this.onBack});

  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        color: MarketingDarkColors.bgAlt,
        border: Border(
          bottom: BorderSide(color: MarketingDarkColors.border),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: MarketingDarkColors.slate400,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      l10n.customersNewCustomer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MarketingDarkColors.text,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: MarketingDarkColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              MarketingDarkColors.brand.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        l10n.customerCreationBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: MarketingDarkColors.brandLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.customerCreationHeaderSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: MarketingDarkColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.customerCreationStepProgress,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: MarketingDarkColors.slate400,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.brand,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 6,
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.surface700,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreationFooter extends StatelessWidget {
  const _CreationFooter({
    required this.l10n,
    required this.saving,
    required this.bottomInset,
    required this.onCancel,
    required this.onSave,
  });

  final AppLocalizations l10n;
  final bool saving;
  final double bottomInset;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 560;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1624),
        border: Border(
          top: BorderSide(color: MarketingDarkColors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!narrow)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                l10n.customerCreationLocalDataHint,
                style: const TextStyle(
                  fontSize: 11,
                  color: MarketingDarkColors.slate400,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MarketingDarkColors.slate300,
                    side: const BorderSide(
                      color: MarketingDarkColors.borderMuted,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MarketingDarkColors.radiusXl,
                      ),
                    ),
                  ),
                  child: Text(l10n.customerCancel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: Text(
                    l10n.customerSaveAndCreatePlan,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: MarketingDarkColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MarketingDarkColors.radiusXl,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (narrow) ...[
            const SizedBox(height: 8),
            Text(
              l10n.customerCreationLocalDataHint,
              style: const TextStyle(
                fontSize: 11,
                color: MarketingDarkColors.slate400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
