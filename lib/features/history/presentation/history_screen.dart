import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/image_preview.dart';
import '../../result/presentation/result_screen.dart';
import '../../result/presentation/widgets/food_level_badge.dart';
import '../../scan/domain/analysis_record.dart';
import '../../scan/domain/nutrition_level.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);
    final records = historyState.visibleRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (historyState.records.isNotEmpty)
            IconButton(
              tooltip: 'Hapus history',
              onPressed: () =>
                  ref.read(historyControllerProvider.notifier).clear(),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyState.records.isEmpty
          ? const _EmptyHistory()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                AnimatedEntry(
                  child: _HistorySummary(total: historyState.records.length),
                ),
                const SizedBox(height: 14),
                _HistorySearchAndFilter(state: historyState),
                const SizedBox(height: 14),
                if (records.isEmpty)
                  const _EmptySearchResult()
                else
                  for (final (index, record) in records.indexed) ...[
                    AnimatedEntry(
                      delay: Duration(milliseconds: index * 45),
                      child: _HistoryRecordCard(record: record),
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }
}

class _HistorySearchAndFilter extends ConsumerWidget {
  const _HistorySearchAndFilter({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(historyControllerProvider.notifier);

    return Column(
      children: [
        TextField(
          onChanged: controller.setQuery,
          decoration: InputDecoration(
            hintText: 'Cari makanan',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: state.levelFilter == null,
                onSelected: (_) => controller.setLevelFilter(null),
              ),
              const SizedBox(width: 8),
              for (final level in NutritionLevel.values) ...[
                FilterChip(
                  label: Text('Level ${level.label}'),
                  selected: state.levelFilter == level,
                  onSelected: (_) => controller.setLevelFilter(level),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({required this.record});

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context) {
    final nutrition = record.nutritionItem;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: ImagePreview(
                    path: record.imagePath,
                    fallback: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      child: const Icon(Icons.restaurant_menu),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nutrition.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (record.wasCorrected)
                          const Icon(Icons.edit_note, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nutrition.calories} kkal • ${record.portionLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.historyDate(record.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FoodLevelBadge(level: nutrition.level),
            ],
          ),
        ),
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
                    'Cari, filter, dan buka ulang hasil scan kapan pun.',
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

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: Text('Nggak ada history yang cocok.')),
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
