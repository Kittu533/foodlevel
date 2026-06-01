import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/transitions/vibrant_page_route.dart';
import '../../../core/theme/motion_preference.dart';
import '../../../core/utils/haptic_controller.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/confetti_burst.dart';
import '../../../shared/widgets/image_preview.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/soft_chip.dart';
import '../../guide/presentation/nutri_level_guide_screen.dart';
import '../../history/presentation/history_controller.dart';
import '../../scan/data/nutrition_repository.dart';
import '../../scan/domain/analysis_record.dart';
import '../../scan/domain/nutrition_item.dart';
import '../../scan/domain/nutrition_level.dart';
import 'widgets/food_level_badge.dart';
import 'widgets/metric_max_reference.dart';
import 'widgets/nutrition_metric_tile.dart';
import 'widgets/prediction_confidence_list.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.record, super.key});

  final AnalysisRecord record;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late NutritionItem _baseNutrition;
  late _PortionOption _portion;

  /// Controller for the confetti burst overlay.
  final ConfettiBurstController _confettiBurstCtrl = ConfettiBurstController();

  /// Whether the "Simpan ke History" action has been triggered.
  bool _isSaved = false;

  AnalysisRecord get _currentRecord {
    return widget.record.copyWith(
      nutritionItem: _baseNutrition.scaledBy(
        _portion.multiplier,
        _portion.label,
      ),
      portionLabel: _portion.label,
      portionMultiplier: _portion.multiplier,
      wasCorrected:
          _baseNutrition.slug != widget.record.nutritionItem.slug ||
          _portion.multiplier != widget.record.portionMultiplier,
    );
  }

  @override
  void initState() {
    super.initState();
    _baseNutrition = widget.record.nutritionItem;
    _portion = _PortionOption.fromMultiplier(widget.record.portionMultiplier);
  }

  @override
  void dispose() {
    _confettiBurstCtrl.dispose();
    super.dispose();
  }

  void _onBadgeRevealComplete() {
    if (widget.record.nutritionItem.level == NutritionLevel.a) {
      _confettiBurstCtrl.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionItems = ref.watch(nutritionRepositoryProvider).items;
    final record = _currentRecord;
    final nutrition = record.nutritionItem;

    // Stagger base for metric tiles: 80ms × index.
    const metricStaggerStep = Duration(milliseconds: 80);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis')),
      body: Stack(
        children: [
          // ── Main scrollable content ────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Food image hero section.
              AnimatedEntry(
                child: _FoodImageHero(record: record),
              ),
              const SizedBox(height: 16),

              // Food name, category chips, and badge.
              AnimatedEntry(
                delay: const Duration(milliseconds: 80),
                child: SectionCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nutrition.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SoftChip(
                                  label: nutrition.category,
                                  icon: Icons.category_outlined,
                                ),
                                SoftChip(
                                  label: nutrition.servingSize,
                                  icon: Icons.room_service_outlined,
                                  color: const Color(0xFFEA580C),
                                ),
                                if (record.wasCorrected)
                                  const SoftChip(
                                    label: 'Dikoreksi',
                                    icon: Icons.edit_note,
                                    color: Color(0xFF7C3AED),
                                  ),
                              ],
                            ),
                            if (record.isLowConfidence) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Sistem kurang yakin. Pilih makanan manual kalau hasilnya meleset.',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Badge with reveal host — triggers confetti for level A.
                      _BadgeRevealHost(
                        level: nutrition.level,
                        onRevealComplete: _onBadgeRevealComplete,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Correction card (food selector + portion).
              AnimatedEntry(
                delay: const Duration(milliseconds: 130),
                child: _CorrectionCard(
                  items: nutritionItems,
                  selectedItem: _baseNutrition,
                  selectedPortion: _portion,
                  onItemChanged: (item) {
                    setState(() => _baseNutrition = item);
                  },
                  onPortionChanged: (portion) {
                    setState(() => _portion = portion);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Top predictions with staggered confidence bars.
              AnimatedEntry(
                delay: const Duration(milliseconds: 180),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top prediksi',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 14),
                      PredictionConfidenceList(
                          predictions: record.predictions),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Level insight card.
              AnimatedEntry(
                delay: const Duration(milliseconds: 230),
                child: _LevelInsightCard(level: nutrition.level),
              ),
              const SizedBox(height: 16),

              // Nutrition metrics: column of tiles with AnimatedNutritionBar.
              AnimatedEntry(
                delay: const Duration(milliseconds: 280),
                child: _MetricsSection(
                  nutrition: nutrition,
                  staggerStep: metricStaggerStep,
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons.
              AnimatedEntry(
                delay: const Duration(milliseconds: 340),
                child: Column(
                  children: [
                    // Save to history with animated bookmark icon.
                    _SaveButton(
                      isSaved: _isSaved,
                      onPressed: () {
                        if (_isSaved) return;
                        setState(() => _isSaved = true);
                        HapticController.light();
                        ref
                            .read(historyControllerProvider.notifier)
                            .addRecord(_currentRecord);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hasil disimpan ke history.'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // Open guide screen using VibrantPageRoute.
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          VibrantPageRoute(
                            builder: (_) => const NutriLevelGuideScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Lihat Panduan A-D'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Confetti burst overlay at topmost Stack layer ─────────────────
          if (!MotionPreference.disabled(context))
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiBurst(controller: _confettiBurstCtrl),
              ),
            ),
        ],
      ),
    );
  }
}

// ── _FoodImageHero ──────────────────────────────────────────────────────────

/// Hero-wrapped food image shown at the top of the result screen.
///
/// Uses `Hero(tag: 'food-image-${record.id}')` for shared-element transitions.
/// Background uses `colorScheme.surfaceContainerHighest` instead of the
/// hardcoded `Color(0xFF111827)`.
///
/// Requirements: 5.1, 5.2
class _FoodImageHero extends StatelessWidget {
  const _FoodImageHero({required this.record});

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'food-image-${record.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImagePreview(
                path: record.imagePath,
                fallback: DecoratedBox(
                  decoration: BoxDecoration(
                    // Theme-driven background instead of hardcoded #111827.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surfaceContainerHigh,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 72,
                      color: colorScheme.onSurface.withValues(alpha: 0.40),
                    ),
                  ),
                ),
              ),
              // Gradient overlay for text legibility.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.68),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    const SoftChip(
                      label: 'AI scan result',
                      icon: Icons.auto_awesome_outlined,
                      color: Color(0xFF22C55E),
                    ),
                    const Spacer(),
                    Text(
                      '${(record.topPrediction.confidence * 100).round()}%',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
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

// ── _BadgeRevealHost ────────────────────────────────────────────────────────

/// Hosts [FoodLevelBadge] and fires the confetti burst for level A after the
/// badge reveal animation completes.
///
/// Uses `WidgetsBinding.addPostFrameCallback` to schedule the confetti
/// trigger on the first frame after the widget is mounted, giving the badge
/// time to start its reveal animation before confetti plays.
///
/// Requirements: 6.3, 6.5, 6.7
class _BadgeRevealHost extends StatefulWidget {
  const _BadgeRevealHost({
    required this.level,
    required this.onRevealComplete,
  });

  final NutritionLevel level;

  /// Called after the badge reveal completes when level is [NutritionLevel.a].
  final VoidCallback onRevealComplete;

  @override
  State<_BadgeRevealHost> createState() => _BadgeRevealHostState();
}

class _BadgeRevealHostState extends State<_BadgeRevealHost> {
  @override
  void initState() {
    super.initState();
    // Schedule confetti trigger after badge reveal completes.
    // Badge reveal is AnimationBudget.badgeReveal = 600ms. We add a small
    // buffer (50ms) for the animation to settle before firing confetti.
    if (widget.level == NutritionLevel.a) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Delay by badge reveal duration + small buffer so confetti starts
        // right as the badge settles into place.
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) {
            widget.onRevealComplete();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FoodLevelBadge(
      level: widget.level,
      animateReveal: true,
      glowOnReveal: true,
    );
  }
}

// ── _MetricsSection ─────────────────────────────────────────────────────────

/// Renders 6 nutrition metric tiles in a 2-column grid layout.
///
/// Each tile uses [NutritionMetricTile] which internally contains an
/// [AnimatedNutritionBar]. Tiles are staggered at 80ms × index so the bars
/// fill in sequence.
///
/// Requirements: 6.1, 6.2
class _MetricsSection extends StatelessWidget {
  const _MetricsSection({
    required this.nutrition,
    required this.staggerStep,
  });

  final NutritionItem nutrition;
  final Duration staggerStep;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        label: 'Kalori',
        value: '${nutrition.calories} kkal',
        icon: Icons.local_fire_department_outlined,
        rawValue: nutrition.calories.toDouble(),
        maxReference: MetricMaxReference.calories,
      ),
      _MetricData(
        label: 'Gula',
        value: '${nutrition.sugarGram} g',
        icon: Icons.water_drop_outlined,
        rawValue: nutrition.sugarGram,
        maxReference: MetricMaxReference.sugarGram,
      ),
      _MetricData(
        label: 'Sodium',
        value: '${nutrition.sodiumMg} mg',
        icon: Icons.grain_outlined,
        rawValue: nutrition.sodiumMg.toDouble(),
        maxReference: MetricMaxReference.sodiumMg,
      ),
      _MetricData(
        label: 'Lemak',
        value: '${nutrition.fatGram} g',
        icon: Icons.oil_barrel_outlined,
        rawValue: nutrition.fatGram,
        maxReference: MetricMaxReference.fatGram,
      ),
      _MetricData(
        label: 'Protein',
        value: '${nutrition.proteinGram} g',
        icon: Icons.fitness_center_outlined,
        rawValue: nutrition.proteinGram,
        maxReference: MetricMaxReference.proteinGram,
      ),
      _MetricData(
        label: 'Karbo',
        value: '${nutrition.carbsGram} g',
        icon: Icons.rice_bowl_outlined,
        rawValue: nutrition.carbsGram,
        maxReference: MetricMaxReference.carbsGram,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i = 0; i < metrics.length; i++)
          NutritionMetricTile(
            label: metrics[i].label,
            value: metrics[i].value,
            icon: metrics[i].icon,
            rawValue: metrics[i].rawValue,
            maxReference: metrics[i].maxReference,
            delay: staggerStep * i,
          ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.rawValue,
    required this.maxReference,
  });

  final String label;
  final String value;
  final IconData icon;
  final double rawValue;
  final double maxReference;
}

// ── _SaveButton ─────────────────────────────────────────────────────────────

/// "Simpan ke History" button with an animated icon swap between
/// [Icons.bookmark_add_outlined] and [Icons.bookmark] on tap.
///
/// Uses [AnimatedSwitcher] with a 250ms duration for the icon swap.
/// Also triggers [HapticController.light()] on press.
///
/// Requirements: 11.1, 11.2, 11.3
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSaved,
    required this.onPressed,
  });

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
          key: ValueKey<bool>(isSaved),
        ),
      ),
      label: Text(isSaved ? 'Tersimpan' : 'Simpan ke History'),
    );
  }
}

// ── _CorrectionCard ──────────────────────────────────────────────────────────

class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({
    required this.items,
    required this.selectedItem,
    required this.selectedPortion,
    required this.onItemChanged,
    required this.onPortionChanged,
  });

  final List<NutritionItem> items;
  final NutritionItem selectedItem;
  final _PortionOption selectedPortion;
  final ValueChanged<NutritionItem> onItemChanged;
  final ValueChanged<_PortionOption> onPortionChanged;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Koreksi hasil',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedItem.slug,
            decoration: InputDecoration(
              labelText: 'Makanan terdeteksi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              for (final item in items)
                DropdownMenuItem(value: item.slug, child: Text(item.name)),
            ],
            onChanged: (slug) {
              final item = items.firstWhere((item) => item.slug == slug);
              onItemChanged(item);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Porsi',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final portion in _PortionOption.values)
                ChoiceChip(
                  label: Text(portion.label),
                  selected: selectedPortion == portion,
                  onSelected: (_) => onPortionChanged(portion),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── _PortionOption ───────────────────────────────────────────────────────────

class _PortionOption {
  const _PortionOption(this.label, this.multiplier);

  final String label;
  final double multiplier;

  static const values = [
    _PortionOption('Kecil', 0.5),
    _PortionOption('Normal', 1),
    _PortionOption('Besar', 1.5),
    _PortionOption('Double', 2),
  ];

  static _PortionOption fromMultiplier(double multiplier) {
    return values.firstWhere(
      (portion) => portion.multiplier == multiplier,
      orElse: () => values[1],
    );
  }
}

// ── _LevelInsightCard ────────────────────────────────────────────────────────

class _LevelInsightCard extends StatelessWidget {
  const _LevelInsightCard({required this.level});

  final NutritionLevel level;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kenapa Level ${level.label}?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(level.description),
          const SizedBox(height: 14),
          _InsightRow(
            icon: Icons.rule_outlined,
            title: 'Kriteria',
            body: level.criteria,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.lightbulb_outline,
            title: 'Saran',
            body: _suggestionFor(level),
          ),
        ],
      ),
    );
  }

  String _suggestionFor(NutritionLevel level) {
    return switch (level) {
      NutritionLevel.a =>
        'Gas buat pilihan harian. Tetap jaga variasi makanan.',
      NutritionLevel.b => 'Masih oke, tapi cek porsi kalau dikonsumsi sering.',
      NutritionLevel.c =>
        'Nikmati sesekali, lebih aman kalau porsinya dikurangi.',
      NutritionLevel.d =>
        'Batasi frekuensi dan cari alternatif yang gula/garamnya lebih rendah.',
    };
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
