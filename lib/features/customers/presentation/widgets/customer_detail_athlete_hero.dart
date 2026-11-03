import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercoach_studio/core/theme/marketing_dark_colors.dart';
import 'package:powercoach_studio/features/customers/data/models/customer.dart';
import 'package:powercoach_studio/features/customers/domain/customer_progress_metrics.dart';
import 'package:powercoach_studio/features/customers/presentation/customer_list_filter.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

class CustomerDetailAthleteHero extends StatelessWidget {
  const CustomerDetailAthleteHero({
    super.key,
    required this.customer,
    required this.goalLabel,
    required this.progressSnapshot,
    required this.l10n,
    required this.locale,
    required this.onAssignWorkout,
    required this.onEditProfile,
  });

  final Customer customer;
  final String goalLabel;
  final CustomerProgressSnapshot? progressSnapshot;
  final AppLocalizations l10n;
  final String locale;
  final VoidCallback onAssignWorkout;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final age = customerAgeYears(customer.dateOfBirth);
    final dob = customer.dateOfBirth != null
        ? DateTime.tryParse(customer.dateOfBirth!)
        : null;
    final email = customer.email?.trim();
    final phone = customer.phone?.trim();
    final lastCheckIn = progressSnapshot?.lastSessionDate;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D1629),
            Color(0xFF0F1B32),
            Color(0xFF0C1426),
          ],
        ),
        borderRadius: BorderRadius.circular(MarketingDarkColors.radius2xl),
        border: Border.all(color: const Color(0xFF1B2A45)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 560;
              final identity = _IdentityBlock(
                customer: customer,
                goalLabel: goalLabel,
                age: age,
                dob: dob,
                email: email,
                phone: phone,
                lastCheckIn: lastCheckIn,
                l10n: l10n,
                locale: locale,
              );
              final actions = _HeroActions(
                l10n: l10n,
                onAssignWorkout: onAssignWorkout,
                onEditProfile: onEditProfile,
              );
              if (stacked) {
                return Column(
                  children: [
                    identity,
                    const SizedBox(height: 20),
                    actions,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 20),
                  SizedBox(width: 220, child: actions),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({
    required this.customer,
    required this.goalLabel,
    required this.age,
    required this.dob,
    required this.email,
    required this.phone,
    required this.lastCheckIn,
    required this.l10n,
    required this.locale,
  });

  final Customer customer;
  final String goalLabel;
  final int? age;
  final DateTime? dob;
  final String? email;
  final String? phone;
  final DateTime? lastCheckIn;
  final AppLocalizations l10n;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                    ),
                    border: Border.all(
                      color: const Color(0xFF1B2B48),
                      width: 4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customerInitials(customer.name),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: MarketingDarkColors.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D1629),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: MarketingDarkColors.text,
                        ),
                      ),
                      if (goalLabel.trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172554).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF1E40AF).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flag_outlined,
                                size: 14,
                                color: MarketingDarkColors.brandLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.customerGoalLabel}: $goalLabel',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: MarketingDarkColors.brandLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      if (age != null && dob != null)
                        _MetaIconText(
                          icon: Icons.calendar_today_outlined,
                          text: l10n.customerAgeWithDob(
                            age!,
                            DateFormat.yMMMd(locale).format(dob!),
                          ),
                        ),
                      if (email != null && email!.isNotEmpty)
                        _MetaIconText(
                          icon: Icons.mail_outline,
                          text: email!,
                        ),
                      if (phone != null && phone!.isNotEmpty)
                        _MetaIconText(
                          icon: Icons.phone_outlined,
                          text: phone!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: l10n.customerJourneyStart,
                        value: DateFormat.yMMMd(locale).format(customer.createdAt),
                      ),
                      if (lastCheckIn != null)
                        _MetaChip(
                          label: l10n.customerLastCheckIn,
                          value: DateFormat.yMMMd(locale).format(lastCheckIn!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaIconText extends StatelessWidget {
  const _MetaIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: MarketingDarkColors.slate500),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: MarketingDarkColors.slate400,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF090F1D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B2940)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: MarketingDarkColors.slate500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 11,
                color: MarketingDarkColors.slate300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.l10n,
    required this.onAssignWorkout,
    required this.onEditProfile,
  });

  final AppLocalizations l10n;
  final VoidCallback onAssignWorkout;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAssignWorkout,
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          label: Text(l10n.customerAssignWorkout),
          style: FilledButton.styleFrom(
            backgroundColor: MarketingDarkColors.brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onEditProfile,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n.customerEditProfile),
          style: OutlinedButton.styleFrom(
            foregroundColor: MarketingDarkColors.slate300,
            side: const BorderSide(color: Color(0xFF233352)),
            backgroundColor: const Color(0xFF131C30),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MarketingDarkColors.radiusXl),
            ),
          ),
        ),
      ],
    );
  }
}
