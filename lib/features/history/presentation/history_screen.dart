import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../result/presentation/widgets/food_level_badge.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? const _EmptyHistory()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                AnimatedEntry(child: _HistorySummary(total: history.length)),
                const SizedBox(height: 14),
                for (final (index, record) in history.indexed) ...[
                  Builder(
                    builder: (context) {
                      final nutrition = record.nutritionItem;

                      return AnimatedEntry(
                        delay: Duration(milliseconds: index * 55),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: FoodLevelBadge(level: nutrition.level),
                            title: Text(
                              nutrition.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${nutrition.calories} kkal • ${Formatters.historyDate(record.createdAt)}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.bookmark_added, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total hasil tersimpan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau pola makanan dari hasil scan yang sudah disimpan.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.76),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.88, end: 1),
              duration: const Duration(milliseconds: 560),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Icon(
                Icons.history_toggle_off_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada history',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Simpan hasil analisis pertama untuk melihat riwayat makanan di sini.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
