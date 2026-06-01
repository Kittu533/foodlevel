import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/transitions/vibrant_page_route.dart';
import '../../../core/theme/vibrant_palette.dart';
import '../../../core/utils/haptic_controller.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/image_preview.dart';
import '../../../shared/widgets/pulse_icon_button.dart';
import '../../../shared/widgets/scanning_beam.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/shimmer_skeleton.dart';
import '../../../shared/widgets/soft_chip.dart';
import '../../history/presentation/history_controller.dart';
import '../../result/presentation/result_screen.dart';
import '../domain/analysis_record.dart';
import '../domain/nutrition_level.dart';
import 'scan_controller.dart';

/// Standalone Scan tab page.
///
/// Replaces the old `_HomeDashboard` widget. Contains:
///   - [_HeroHeader] — theme-driven primary-container banner
///   - Scan card with [PulseIconButton] / gallery button
///   - While loading: [Stack] with image preview + [ScanningBeam] overlay,
///     plus [_ScanResultSkeleton] below
///   - Info chips, last-result card, level preview, how-it-works card
///
/// On success, navigates to [ResultScreen] via [VibrantPageRoute] with
/// `Hero(tag: 'food-image-${record.id}')` wrapping the food image.
///
/// On error / cancel, shows `SnackBar` with the required Indonesian text.
///
/// Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.1, 7.1, 7.4, 8.1, 11.1,
///               12.5, 13.5, 16.1, 16.2, 16.3, 16.4
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  /// Image path displayed in the preview area while loading.  Kept locally so
  /// the preview persists between `setState` rebuilds.
  String? _previewImagePath;

  /// When non-null, the image preview is wrapped in a Hero with this record's
  /// id as the tag.  This ensures the Hero source is in the tree at the
  /// moment [Navigator.push] is called, enabling the shared-element
  /// transition to [ResultScreen].
  ///
  /// Requirements: 5.1
  AnalysisRecord? _heroRecord;

  // ── Pick & analyze ─────────────────────────────────────────────────────────

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final record = await ref
        .read(scanControllerProvider.notifier)
        .pickAndAnalyze(source);

    if (!mounted) return;

    final scanState = ref.read(scanControllerProvider);

    // Keep the preview image updated for the beam overlay.
    if (scanState.latestRecord != null) {
      setState(() => _previewImagePath = scanState.latestRecord!.imagePath);
    }

    if (record == null) {
      // Error or cancel — friendly Indonesian SnackBar (Req 4.5, 16.1).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yah, gak jadi nih. Coba lagi ya 📸'),
        ),
      );
      return;
    }

    // Success: light haptic → navigate via VibrantPageRoute (Req 4.6, 8.1).
    await HapticController.light();
    if (!mounted) return;

    // Req 5.1: Register the Hero source in the tree by setting [_heroRecord]
    // so the image preview is wrapped with the matching tag before pushing.
    setState(() => _heroRecord = record);

    // Wait one frame so the Hero widget is present in the source tree before
    // the Navigator.push starts the shared-element transition.
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      VibrantPageRoute(
        builder: (_) => ResultScreen(record: record),
      ),
    );

    // Clear the hero record after returning from the result screen.
    if (mounted) {
      setState(() => _heroRecord = null);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);
    final historyState = ref.watch(historyControllerProvider);
    final latestRecord = historyState.records.firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        // ── Hero banner ─────────────────────────────────────────────────────
        const AnimatedEntry(child: _HeroHeader()),
        const SizedBox(height: 20),

        // ── Scan card ───────────────────────────────────────────────────────
        AnimatedEntry(
          delay: const Duration(milliseconds: 90),
          child: SectionCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ambil foto atau pilih dari galeri. AI mock akan kasih top prediksi dan nutrisi dummy dulu.',
                ),
                const SizedBox(height: 16),

                // Loading / idle switcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: scanState.isLoading
                      ? _ScanLoadingState(
                          imagePath: _previewImagePath,
                          heroRecord: _heroRecord,
                        )
                      : _heroRecord != null
                          ? _ScanLoadingState(
                              imagePath: _previewImagePath,
                              heroRecord: _heroRecord,
                            )
                          : _ScanIdleActions(
                              key: const ValueKey('scan-actions'),
                              onPickImage: _pickAndAnalyze,
                            ),
                ),

                // Inline error message from the controller
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

        // ── Chips ────────────────────────────────────────────────────────────
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
              ),
              SoftChip(
                label: '${historyState.records.length} saved',
                icon: Icons.bookmark_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Last result card ─────────────────────────────────────────────────
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
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

        // ── Level preview ────────────────────────────────────────────────────
        const AnimatedEntry(
          delay: Duration(milliseconds: 280),
          child: _LevelPreview(),
        ),
        const SizedBox(height: 16),

        // ── How it works ─────────────────────────────────────────────────────
        const AnimatedEntry(
          delay: Duration(milliseconds: 340),
          child: _HowItWorksCard(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero header
// ─────────────────────────────────────────────────────────────────────────────

/// Top banner on the Scan tab.
///
/// Background is [ColorScheme.primaryContainer] — no hardcoded [Color].
/// Text and icon colors are derived from [ColorScheme.onPrimaryContainer].
///
/// Requirements: 1.6, 12.1, 12.2
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
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
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftChip(
                  label: 'MVP mode',
                  icon: Icons.bolt_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  'FoodLevel',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan makanan, cek nutrisi, simpan history. Cepat, clean, dan siap naik kelas ke TFLite.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        colorScheme.onPrimaryContainer.withValues(alpha: 0.78),
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

// ─────────────────────────────────────────────────────────────────────────────
// Scan idle state
// ─────────────────────────────────────────────────────────────────────────────

/// Camera + gallery action buttons shown while not scanning.
class _ScanIdleActions extends StatelessWidget {
  const _ScanIdleActions({required this.onPickImage, super.key});

  final Future<void> Function(ImageSource source) onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Req 13.5, 16.2: explicit Semantics label in Bahasa Indonesia for
        // screen-reader accessibility.
        Semantics(
          label: 'Ambil foto makanan menggunakan kamera',
          child: PulseIconButton(
            onPressed: () => onPickImage(ImageSource.camera),
            icon: Icons.photo_camera_outlined,
            label: 'Ambil Foto',
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Pilih foto makanan dari galeri',
          child: OutlinedButton.icon(
            onPressed: () => onPickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Pilih dari Galeri'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan loading state
// ─────────────────────────────────────────────────────────────────────────────

/// Image preview with [ScanningBeam] overlay + [_ScanResultSkeleton] below.
///
/// When [heroRecord] is non-null the image is wrapped in a
/// `Hero(tag: 'food-image-${heroRecord.id}')` so the shared-element
/// transition to [ResultScreen] can animate.
///
/// Requirements: 4.1, 4.2, 5.1
class _ScanLoadingState extends StatelessWidget {
  const _ScanLoadingState({required this.imagePath, this.heroRecord});

  final String? imagePath;

  /// When set, wraps the image in a Hero with `food-image-${heroRecord.id}`.
  final AnalysisRecord? heroRecord;

  @override
  Widget build(BuildContext context) {
    Widget imageContent = imagePath != null
        ? ImagePreview(
            path: imagePath!,
            fit: BoxFit.cover,
            fallback: _ImagePlaceholder(),
          )
        : _ImagePlaceholder();

    // Req 5.1: wrap in Hero when we have a record ready for navigation.
    if (heroRecord != null) {
      imageContent = Hero(
        tag: 'food-image-${heroRecord!.id}',
        child: imageContent,
      );
    }

    return Column(
      key: const ValueKey('scanning-state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image preview + scanning beam
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Food image (or placeholder), optionally Hero-wrapped
                imageContent,

                // Scanning beam overlay (Req 4.1)
                const Positioned.fill(
                  child: ScanningBeam(active: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Shimmer skeleton for pending result (Req 4.2)
        const _ScanResultSkeleton(),
      ],
    );
  }
}

/// Placeholder shown in the preview area before any image is selected.
class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Shimmer skeleton composition shown below the image preview while scanning.
///
/// Layout mirrors an upcoming result card:
/// - Title line  (food name placeholder)
/// - Two chip boxes  (category + serving size)
/// - Three prediction-bar lines
///
/// Requirements: 4.2
class _ScanResultSkeleton extends StatelessWidget {
  const _ScanResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title / food name placeholder
        ShimmerSkeleton.line(
          width: double.infinity,
          height: 22,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 10),

        // Chip-row placeholders
        Row(
          children: [
            ShimmerSkeleton.box(
              width: 80,
              height: 28,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(width: 8),
            ShimmerSkeleton.box(
              width: 100,
              height: 28,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Prediction bar placeholders
        ShimmerSkeleton.line(
          width: double.infinity,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        ShimmerSkeleton.line(
          width: double.infinity,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        ShimmerSkeleton.line(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level preview
// ─────────────────────────────────────────────────────────────────────────────

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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
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

/// Single level pill using [context.vibrantPalette] for all colors.
///
/// No hardcoded [Color] values — requirements: 3.2, 12.5
class _MiniLevelPill extends StatelessWidget {
  const _MiniLevelPill({required this.level});

  final NutritionLevel level;

  @override
  Widget build(BuildContext context) {
    final palette = context.vibrantPalette;
    final bgColor = palette.colorOf(level);
    final fgColor = palette.onColorOf(level);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            level.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How it works
// ─────────────────────────────────────────────────────────────────────────────

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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
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
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
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
