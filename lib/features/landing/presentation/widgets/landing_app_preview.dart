import 'package:flutter/material.dart';

import '../landing_colors.dart';

/// Simplified dark dashboard mock under the hero (Stitch `app-preview`).
class LandingAppPreview extends StatelessWidget {
  const LandingAppPreview({super.key, required this.editorLabel});

  final String editorLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 960),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LandingColors.radius2xl),
        border: Border.all(color: LandingColors.borderMuted),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF334155).withValues(alpha: 0.6),
            const Color(0xFF1E293B).withValues(alpha: 0.4),
            const Color(0xFF0F172A).withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: LandingColors.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: LandingColors.surfaceElevated,
                child: Row(
                  children: [
                    _Dot(const Color(0xFFF43F5E)),
                    const SizedBox(width: 6),
                    _Dot(const Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    _Dot(const Color(0xFF10B981)),
                    const SizedBox(width: 12),
                    Text(
                      'coach-studio.app',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: LandingColors.textDim,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LandingColors.brand.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'PC',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: LandingColors.brandSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth >= 560 ? 4 : 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final m in _metrics)
                          SizedBox(
                            width: (constraints.maxWidth - (cols - 1) * 10) /
                                cols,
                            child: _MetricTile(
                              label: m.$1,
                              value: m.$2,
                              icon: m.$3,
                              valueColor: m.$4,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Divider(height: 1, color: LandingColors.border.withValues(alpha: 0.8)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editorLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: LandingColors.slate300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _PreviewRow(
                      index: '1',
                      title: 'Squat con bilanciere (Low Bar)',
                      subtitle: '4 × 6 @ 78% 1RM · RIR 2 · Rest 180s',
                      chip: 'Progressione',
                    ),
                    const SizedBox(height: 8),
                    const _PreviewRow(
                      index: '2',
                      title: 'Panca Piana con Bilanciere',
                      subtitle: '5 × 5 @ 82.5% · Rest 150s',
                      chip: 'Set Fisso',
                    ),
                    const SizedBox(height: 8),
                    const _PreviewRow(
                      index: 'SS',
                      title: 'Alzate laterali + Rematore',
                      subtitle: '3 × 12+10 · Tensione continua',
                      chip: 'Superset',
                      accent: LandingColors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _metrics = <(String, String, IconData, Color)>[
  ('Atleti', '18', Icons.people_outline, Colors.white),
  ('Schede', '24', Icons.assignment_outlined, Colors.white),
  ('Sessioni', '142', Icons.check_circle_outline, LandingColors.emerald),
  ('Avvisi', '0', Icons.verified_outlined, LandingColors.emerald),
];

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LandingColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LandingColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LandingColors.textDim,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 16, color: LandingColors.brandLight),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.chip,
    this.accent = LandingColors.brandLight,
  });

  final String index;
  final String title;
  final String subtitle;
  final String chip;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LandingColors.surfaceRow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent == LandingColors.indigo
              ? const Color(0xFF312E81).withValues(alpha: 0.4)
              : LandingColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              index,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LandingColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Text(
              chip,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
