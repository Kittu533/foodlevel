import 'package:flutter/material.dart';

import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/section_card.dart';
import '../../result/presentation/widgets/food_level_badge.dart';
import '../../scan/domain/nutrition_level.dart';

class NutriLevelGuideScreen extends StatelessWidget {
  const NutriLevelGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const levels = NutritionLevel.values;

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Nutri Level')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const AnimatedEntry(child: _GuideHero()),
          const SizedBox(height: 16),
          for (final (index, level) in levels.indexed) ...[
            AnimatedEntry(
              delay: Duration(milliseconds: 80 * (index + 1)),
              child: _LevelGuideCard(level: level),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          AnimatedEntry(
            delay: const Duration(milliseconds: 430),
            child: SectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Untuk MVP, level masih dari data dummy. Nanti rule ini bisa dibuat lebih presisi di backend dan admin panel.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  const _GuideHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF4C1D95),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -22,
            child: Icon(
              Icons.school_outlined,
              size: 142,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kenalan dengan Nutri Level A-D',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dari paling sehat sampai yang perlu dibatasi. Dibikin singkat biar gampang dipakai saat milih makanan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelGuideCard extends StatelessWidget {
  const _LevelGuideCard({required this.level});

  final NutritionLevel level;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodLevelBadge(level: level),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(level.description),
                const SizedBox(height: 10),
                _InfoLine(icon: Icons.rule_outlined, text: level.criteria),
                const SizedBox(height: 6),
                _InfoLine(icon: Icons.fastfood_outlined, text: level.examples),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
