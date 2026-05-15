import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/pulse_icon_button.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/soft_chip.dart';
import '../../guide/presentation/nutri_level_guide_screen.dart';
import '../../history/presentation/history_controller.dart';
import '../../history/presentation/history_screen.dart';
import '../../result/presentation/result_screen.dart';
import '../../scan/domain/nutrition_level.dart';
import '../../scan/presentation/scan_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeDashboard(onPickImage: _pickImage),
      const NutriLevelGuideScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final record = await ref
        .read(scanControllerProvider.notifier)
        .pickAndAnalyze(source);

    if (!mounted || record == null) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
    );
  }
}

class _HomeDashboard extends ConsumerWidget {
  const _HomeDashboard({required this.onPickImage});

  final Future<void> Function(ImageSource source) onPickImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanControllerProvider);
    final history = ref.watch(historyControllerProvider);
    final latestRecord = history.firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        const AnimatedEntry(child: _HeroHeader()),
        const SizedBox(height: 20),
        AnimatedEntry(
          delay: const Duration(milliseconds: 90),
          child: SectionCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.document_scanner_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Scan makanan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ambil foto atau pilih dari galeri. AI mock akan kasih top prediksi dan nutrisi dummy dulu.',
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: scanState.isLoading
                      ? const _ScanningState()
                      : Column(
                          key: const ValueKey('scan-actions'),
                          children: [
                            PulseIconButton(
                              onPressed: () => onPickImage(ImageSource.camera),
                              icon: Icons.photo_camera_outlined,
                              label: 'Ambil Foto',
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => onPickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Pilih dari Galeri'),
                            ),
                          ],
                        ),
                ),
                if (scanState.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    scanState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedEntry(
          delay: const Duration(milliseconds: 160),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              const SoftChip(
                label: 'Top 3 AI',
                icon: Icons.auto_awesome_outlined,
                color: Color(0xFF7C3AED),
              ),
              SoftChip(
                label: '${history.length} saved',
                icon: Icons.bookmark_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedEntry(
          delay: const Duration(milliseconds: 220),
          child: SectionCard(
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: const Icon(Icons.insights_outlined, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestRecord == null
                            ? 'Belum ada hasil terakhir'
                            : latestRecord.nutritionItem.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestRecord == null
                            ? 'History akan muncul setelah hasil disimpan.'
                            : 'Level ${latestRecord.nutritionItem.level.label} • ${latestRecord.nutritionItem.calories} kkal',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const AnimatedEntry(
          delay: Duration(milliseconds: 280),
          child: _LevelPreview(),
        ),
        const SizedBox(height: 16),
        const AnimatedEntry(
          delay: Duration(milliseconds: 340),
          child: _HowItWorksCard(),
        ),
      ],
    );
  }
}

class _LevelPreview extends StatelessWidget {
  const _LevelPreview();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutri Level A-D',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final level in NutritionLevel.values)
                Expanded(child: _MiniLevelPill(level: level)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A paling aman buat harian, D sebaiknya dibatasi. Detailnya ada di tab Guide.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MiniLevelPill extends StatelessWidget {
  const _MiniLevelPill({required this.level});

  final NutritionLevel level;

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      NutritionLevel.a => const Color(0xFF059669),
      NutritionLevel.b => const Color(0xFF7AC943),
      NutritionLevel.c => const Color(0xFFFBBF24),
      NutritionLevel.d => const Color(0xFFDC2626),
    };

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            level.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow-nya gimana?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const _StepTile(
            number: '1',
            title: 'Upload foto',
            body: 'Ambil foto makanan atau pilih dari galeri.',
          ),
          const _StepTile(
            number: '2',
            title: 'AI kasih prediksi',
            body: 'MVP masih mock, nanti diganti TFLite on-device.',
          ),
          const _StepTile(
            number: '3',
            title: 'Lihat level',
            body: 'App tampilkan nutrisi, level A-D, dan saran singkat.',
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.14),
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Transform.rotate(
              angle: -0.18,
              child: Icon(
                Icons.eco_outlined,
                size: 132,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SoftChip(
                  label: 'MVP mode',
                  icon: Icons.bolt_outlined,
                  color: Color(0xFF22C55E),
                ),
                const SizedBox(height: 18),
                Text(
                  'FoodLevel',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan makanan, cek nutrisi, simpan history. Cepat, clean, dan siap naik kelas ke TFLite.',
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

class _ScanningState extends StatelessWidget {
  const _ScanningState();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('scanning-state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(minHeight: 8),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(Icons.auto_awesome_outlined),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text('Lagi baca foto dan nyiapin hasil...')),
          ],
        ),
      ],
    );
  }
}
