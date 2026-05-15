import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/soft_chip.dart';
import '../../guide/presentation/nutri_level_guide_screen.dart';
import '../../history/presentation/history_controller.dart';
import '../../scan/domain/analysis_record.dart';
import '../../scan/domain/nutrition_level.dart';
import 'widgets/food_level_badge.dart';
import 'widgets/nutrition_metric_tile.dart';
import 'widgets/prediction_confidence_list.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({required this.record, super.key});

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = record.nutritionItem;

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AnimatedEntry(
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -24,
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 136,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1),
                      duration: const Duration(milliseconds: 520),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(22),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                          style: Theme.of(context).textTheme.headlineSmall
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
                          ],
                        ),
                        if (record.isLowConfidence) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Sistem kurang yakin. User sebaiknya konfirmasi manual.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FoodLevelBadge(level: nutrition.level),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntry(
            delay: const Duration(milliseconds: 140),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top prediksi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PredictionConfidenceList(predictions: record.predictions),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntry(
            delay: const Duration(milliseconds: 200),
            child: _LevelInsightCard(level: nutrition.level),
          ),
          const SizedBox(height: 16),
          AnimatedEntry(
            delay: const Duration(milliseconds: 260),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                NutritionMetricTile(
                  label: 'Kalori',
                  value: '${nutrition.calories} kkal',
                  icon: Icons.local_fire_department_outlined,
                ),
                NutritionMetricTile(
                  label: 'Gula',
                  value: '${nutrition.sugarGram} g',
                  icon: Icons.water_drop_outlined,
                ),
                NutritionMetricTile(
                  label: 'Sodium',
                  value: '${nutrition.sodiumMg} mg',
                  icon: Icons.grain_outlined,
                ),
                NutritionMetricTile(
                  label: 'Lemak',
                  value: '${nutrition.fatGram} g',
                  icon: Icons.oil_barrel_outlined,
                ),
                NutritionMetricTile(
                  label: 'Protein',
                  value: '${nutrition.proteinGram} g',
                  icon: Icons.fitness_center_outlined,
                ),
                NutritionMetricTile(
                  label: 'Karbo',
                  value: '${nutrition.carbsGram} g',
                  icon: Icons.rice_bowl_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedEntry(
            delay: const Duration(milliseconds: 320),
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(historyControllerProvider.notifier)
                        .addRecord(record);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hasil disimpan ke history.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Simpan ke History'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
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
    );
  }
}

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
