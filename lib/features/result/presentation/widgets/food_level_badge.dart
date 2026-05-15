import 'package:flutter/material.dart';

import '../../../scan/domain/nutrition_level.dart';

class FoodLevelBadge extends StatelessWidget {
  const FoodLevelBadge({required this.level, super.key});

  final NutritionLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      NutritionLevel.a => const Color(0xFF2E7D32),
      NutritionLevel.b => const Color(0xFF6A9F26),
      NutritionLevel.c => const Color(0xFFF9A825),
      NutritionLevel.d => const Color(0xFFC62828),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          level.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
