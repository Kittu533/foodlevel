# Implementation Plan: UI Vibrant Refresh

## Overview

Convert the Vibrant Earth UI refresh design into incremental, testable Flutter coding steps. The plan builds the foundation (palette, animation budget, motion preference, haptic util, page route, dependencies) first, then refreshes the existing shared widgets, then adds the new animation widgets, then wires them into the screens, and finally tightens up with widget/integration/golden tests.

The implementation language is **Dart / Flutter** (matches the existing project and the design document). No domain models, controllers, or repositories are touched — this is strictly a UI/theme/animation layer refresh.

The design explicitly states that **Property-Based Testing is not used** for this feature (UI rendering + theme configuration sit outside PBT's sweet spot, see Testing Strategy → "Why no Property-Based Testing"). Tests use widget tests, parameterized tests, golden tests, and mock-based unit tests.

## Tasks

- [x] 1. Foundation: theme engine, palette, animation budget, motion preference, haptic util, page route, dependencies
  - [x] 1.1 Add UI animation dependencies to `pubspec.yaml`
    - Add `flutter_animate`, `shimmer`, `lottie` (optional), `confetti` (optional) under `dependencies`
    - Add `assets/animations/` block under `flutter.assets`
    - Run `flutter pub get` to lock versions
    - Verify no native (`android/`, `ios/`) setup is required for any added package
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.6_

  - [x] 1.2 Create `lib/core/theme/vibrant_palette.dart`
    - Define `VibrantBrand` abstract final class with `matchaGreen`, `terracottaOrange`, `mustardYellow`, `creamBeige`, `deepCharcoal`, `darkSurface`, `darkSecondary`, `darkTertiary` color constants
    - Define `VibrantLevelPalette extends ThemeExtension<VibrantLevelPalette>` with `levelA/B/C/D` and `onLevelA/B/C/D`, plus `colorOf(level)` and `onColorOf(level)` helpers
    - Provide `VibrantLevelPalette.light` and `VibrantLevelPalette.dark` static instances (level D uses terracotta `#E76F51`, not harsh red)
    - Implement `copyWith` and `lerp` overrides
    - Add `extension VibrantPaletteContext on BuildContext { VibrantLevelPalette get vibrantPalette }`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 3.1, 3.3, 3.5_

  - [x] 1.3 Create `lib/core/theme/animation_budget.dart`
    - Define `AnimationBudget` abstract final class
    - Add base durations: `fast` (150ms), `base` (300ms), `slow` (500ms), `hero` (450ms)
    - Add named durations: `beamLoop` (1500ms), `shimmerLoop` (1200ms), `nutritionBar` (800ms), `badgeReveal` (600ms), `badgeGlow` (1200ms), `badgeShake` (400ms), `confetti` (1500ms), `swipeCollapse` (300ms), `counterTween` (400ms), `reducedMotionFade` (200ms)
    - Add curve constants: `standardCurve` (easeOutCubic), `revealCurve` (elasticOut), `bounceCurve` (easeOutBack)
    - _Requirements: 4.1, 4.3, 5.2, 5.3, 6.1, 6.2, 6.3, 6.4, 6.6, 8.1, 8.2, 8.3, 9.2, 9.5, 11.6_

  - [x] 1.4 Create `lib/core/theme/motion_preference.dart`
    - Define `MotionPreference` abstract final class
    - Implement `disabled(BuildContext)` reading `MediaQuery.maybeOf(context)?.disableAnimations ?? false`
    - Implement `scaled(BuildContext, Duration)` returning `Duration.zero` when disabled
    - Implement `runIfMotion(BuildContext, VoidCallback)` no-op when disabled
    - _Requirements: 13.1_

  - [x] 1.5 Create `lib/core/utils/haptic_controller.dart`
    - Define `HapticController` abstract final class
    - Implement `_enabled` getter returning `false` on web/desktop, `true` on Android/iOS (use `kIsWeb` + `Platform.isAndroid`/`isIOS`)
    - Implement `light()`, `medium()`, `heavy()`, `selection()` static methods that delegate to `HapticFeedback.*` only when `_enabled`, else return `Future.value()` no-op
    - Ensure no `HapticFeedback` channel call happens on web (test guard)
    - _Requirements: 11.4, 11.5_

  - [x] 1.6 Refactor `lib/core/theme/app_theme.dart` to Vibrant Earth (light + dark)
    - Replace existing `light()` to use `ColorScheme.fromSeed(seedColor: VibrantBrand.matchaGreen, brightness: Brightness.light)` then `copyWith` overrides for `secondary`, `tertiary`, `surface`, `onSurface`
    - Set `scaffoldBackgroundColor` to `VibrantBrand.creamBeige`
    - Attach `VibrantLevelPalette.light` via `extensions: const [VibrantLevelPalette.light]`
    - Add `dark()` static using `Brightness.dark` with `secondary`/`tertiary` overrides for dark and `VibrantLevelPalette.dark`
    - Extract shared `_baseTheme(scheme)` builder configuring `appBarTheme`, `cardTheme`, `navigationBarTheme`, `filledButtonTheme`, `outlinedButtonTheme` from `scheme`
    - Remove all hardcoded `Color(0xFF...)` outside `VibrantBrand`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6, 2.1, 2.2, 2.3, 3.4_

  - [x] 1.7 Update `lib/app/app.dart` to register dark theme + system mode
    - Add `darkTheme: AppTheme.dark()` and `themeMode: ThemeMode.system` to `MaterialApp`
    - Keep `theme: AppTheme.light()`
    - _Requirements: 2.5, 2.6_

  - [x] 1.8 Create `lib/app/transitions/vibrant_page_route.dart`
    - Define `VibrantPageRoute<T> extends PageRouteBuilder<T>` with `transitionDuration` 320ms and `reverseTransitionDuration` 240ms
    - In `transitionsBuilder`, branch on `MotionPreference.disabled(context)`:
      - When disabled: `FadeTransition` only with 150ms-equivalent curve `Curves.easeOut`
      - When enabled: combined `FadeTransition` (curve `Curves.easeOutCubic`) + `SlideTransition` from `Offset(0, 0.06)` to `Offset.zero`
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [ ]* 1.9 Write theme + palette unit tests
    - Verify `AppTheme.light()` `scaffoldBackgroundColor == VibrantBrand.creamBeige` and `colorScheme.onSurface == VibrantBrand.deepCharcoal`
    - Verify `AppTheme.dark()` `scaffoldBackgroundColor == VibrantBrand.darkSurface`
    - Verify `VibrantLevelPalette` is attached as extension in both light and dark
    - Verify `palette.colorOf(NutritionLevel.d)` returns terracotta `#E76F51` (not red)
    - _Requirements: 1.1, 1.3, 1.4, 2.1, 2.2, 3.1, 3.5_

- [x] 2. Refresh existing shared widgets (motion-aware, theme-aware) preserving public API
  - [x] 2.1 Refresh `lib/shared/widgets/animated_entry.dart`
    - Keep constructor signature (`child`, `delay`, `offset`, `key`) unchanged
    - Branch on `MotionPreference.disabled(context)`: when true, return `child` directly (no fade/translate)
    - When motion enabled, keep existing fade + translate-up behavior
    - _Requirements: 12.1, 13.2, 13.3_

  - [x] 2.2 Refresh `lib/shared/widgets/pulse_icon_button.dart`
    - Keep constructor signature unchanged
    - Only call `_controller.repeat(reverse: true)` when `!MotionPreference.disabled(context)`
    - On tap: trigger `HapticController.medium()` then run a tap-scale `1.0 → 0.94 → 1.0` over `AnimationBudget.fast`, then call `widget.onPressed`
    - When motion is disabled, skip pulse + tap-scale and call `onPressed` immediately
    - Wrap controller in `TickerMode(enabled: ModalRoute.of(context)?.isCurrent ?? true)` to pause loop when screen is not current
    - Read button color from `Theme.of(context).colorScheme.primary` (already default)
    - _Requirements: 4.3, 4.4, 11.1, 12.1, 12.4, 13.2, 14.2_

  - [x] 2.3 Refresh `lib/shared/widgets/section_card.dart`
    - Keep `child` and `padding` constructor params
    - Add optional `borderRadius` and `tone` named params (defaults read from `Theme.of(context).cardTheme`)
    - Use `Theme.of(context).cardTheme` shape/elevation as fallback (no hardcoded color)
    - _Requirements: 12.1, 12.2_

  - [x] 2.4 Refresh `lib/shared/widgets/soft_chip.dart`
    - Keep public constructor (`label`, `icon`, `color`)
    - Confirm `color ?? Theme.of(context).colorScheme.primary` fallback (already implemented; keep behavior, ensure fallback now resolves to Vibrant Earth primary)
    - _Requirements: 12.1, 12.2, 12.3_

  - [x] 2.5 Refresh `lib/features/result/presentation/widgets/food_level_badge.dart`
    - Add optional non-breaking named params: `size = 56`, `animateReveal = true`, `glowOnReveal = true`
    - Read color from `context.vibrantPalette.colorOf(level)` and text color from `context.vibrantPalette.onColorOf(level)` (no hardcoded `Color(0xFF...)`)
    - Implement reveal: scale `0.6 → 1.0` with `Curves.elasticOut` over `AnimationBudget.badgeReveal`
    - Implement glow ring: stacked container with tween `BoxShadow` opacity `0 → 0.4 → 0` over `AnimationBudget.badgeGlow` when `glowOnReveal == true`
    - For `NutritionLevel.d`, after reveal completes, run shake horizontal `±4px` over `AnimationBudget.badgeShake`
    - When `MotionPreference.disabled(context)` or `animateReveal == false`: render badge at final state, skip reveal/glow/shake
    - Dispose all `AnimationController` instances in `dispose()`
    - _Requirements: 3.2, 3.5, 6.3, 6.4, 12.1, 12.5, 13.2, 13.3, 14.3_

  - [ ]* 2.6 Write widget tests for refreshed shared widgets
    - `AnimatedEntry`: motion off → opacity 1, offset 0 at frame 0; motion on → opacity < 1 at frame 0
    - `PulseIconButton`: tap triggers `onPressed`; motion off → no pulse loop running
    - `FoodLevelBadge`: level D uses `levelD` color (terracotta); motion off → scale 1.0 at first frame; motion on → scale ∈ (0.6, 1.0) mid-`badgeReveal`; level D shows non-zero shake offset after reveal
    - `SoftChip`: with no `color` prop, uses theme primary
    - _Requirements: 3.5, 6.3, 6.4, 12.1, 12.3, 12.5, 13.2_

- [x] 3. Build new shared animation widgets
  - [x] 3.1 Create `lib/shared/widgets/scanning_beam.dart`
    - `ScanningBeam({required bool active, Color? color})` `StatefulWidget`
    - `AnimationController` with `duration: AnimationBudget.beamLoop`; `repeat()` only when `active && !MotionPreference.disabled(context)`
    - Render `Stack` overlay with `Positioned.top` tween `0 → fullHeight` and a vertical `LinearGradient` (transparent → primary alpha-20 → transparent)
    - Wrap in `RepaintBoundary`
    - Implement `WidgetsBindingObserver`: on `paused` stop, on `resumed` restart loop if still active and motion enabled
    - Dispose controller in `dispose()`
    - _Requirements: 4.1, 13.2, 14.2, 14.3, 14.4, 14.5_

  - [x] 3.2 Create `lib/shared/widgets/shimmer_skeleton.dart`
    - `ShimmerSkeleton.line({width, height, borderRadius})`, `.box({...})`, `.circle({size = 40})` named constructors
    - Use `shimmer` package with `baseColor = colorScheme.surfaceContainerHighest`, `highlightColor = colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)`
    - Wrap in `RepaintBoundary`
    - When `MotionPreference.disabled(context)`: render `ColoredBox` (no `Shimmer` widget in tree)
    - _Requirements: 4.2, 13.2, 13.3, 14.5_

  - [x] 3.3 Create `lib/shared/widgets/animated_nutrition_bar.dart`
    - `AnimatedNutritionBar({required label, required valueRatio, required color, duration = AnimationBudget.nutritionBar, delay = Duration.zero, trailingText})`
    - Use `TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: valueRatio), duration: motionOff ? Duration.zero : duration, curve: Curves.easeOutCubic)`
    - Implement `delay` via `Future.delayed` setting an internal `_started` flag (or via parent stagger controller)
    - Wrap row content in `RepaintBoundary`
    - When motion disabled, render bar at `valueRatio` immediately
    - _Requirements: 6.1, 6.2, 13.2, 13.3, 14.5_

  - [x] 3.4 Create `lib/shared/widgets/vibrant_bottom_nav.dart`
    - `VibrantBottomNav({required List<BottomNavItem> items, required int currentIndex, required ValueChanged<int> onTap})`
    - Define `BottomNavItem({required IconData icon, required IconData selectedIcon, required String label})`
    - Render 3 destinations in a `Row` over `Stack` with an `AnimatedPositioned` indicator pill
    - Drive indicator with `AnimationController.animateWith(SpringSimulation(SpringDescription(mass: 1, stiffness: 180, damping: 20), from, to, velocity))`
    - On tab tap: parallel run `HapticController.selection()`, indicator spring, and selected icon scale `1.0 → 1.15 → 1.0` over 250ms with `Curves.easeOutBack`
    - Active indicator color = `colorScheme.primary`; inactive icon color = `colorScheme.onSurfaceVariant`
    - When `MotionPreference.disabled(context)`: instant indicator move (no spring), no scale animation
    - Dispose controllers in `dispose()`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 13.2, 14.3_

  - [x] 3.5 Create `lib/shared/widgets/swipe_to_delete_tile.dart`
    - `SwipeToDeleteTile({required Key itemKey, required Widget child, required Future<bool> Function() onDelete, double threshold = 0.4})`
    - Wrap with `Dismissible(direction: DismissDirection.endToStart, dismissThresholds: {DismissDirection.endToStart: threshold})`
    - `secondaryBackground`: `Container` with `colorScheme.errorContainer` (terracotta-derived) and trash icon whose opacity tweens `0 → 1` based on dismiss progress (use `LayoutBuilder` + `ValueNotifier<double>` driven by gesture)
    - On confirmed dismiss, call `onDelete` and let outer `AnimatedList`/`SizeTransition` handle collapse over `AnimationBudget.swipeCollapse`
    - _Requirements: 9.1, 9.2_

  - [x] 3.6 Create `lib/shared/widgets/confetti_burst.dart`
    - `ConfettiBurst({required ConfettiBurstController controller})` `StatefulWidget`
    - `ConfettiBurstController extends ChangeNotifier` exposing `play()` and `dispose()`
    - Internal `ConfettiController` (from `confetti` package) configured for 1500ms burst
    - Particle colors mixed from `[colorScheme.primary, colorScheme.secondary, colorScheme.tertiary, vibrantPalette.levelA]`
    - On `play()`: if `MotionPreference.disabled(context)`, no-op (skip both confetti and haptic); else trigger `HapticController.heavy()` and start emission
    - Wrap in `RepaintBoundary`
    - _Requirements: 6.5, 6.7, 10.2, 10.3, 13.2, 13.4, 14.3, 14.5_

  - [x] 3.7 Create `lib/shared/widgets/empty_state_illustration.dart`
    - `EmptyStateIllustration({required String assetPath, required String message, Duration maxLoopDuration = const Duration(seconds: 30)})`
    - Try `Lottie.asset(assetPath, controller: _ctrl)` with a `Timer(maxLoopDuration, () => controller.stop())` to stop loop after 30s
    - Catch `FlutterError` for missing asset and fall back to implicit animation: icon `restaurant_menu` rotated `±5°` with `TweenAnimationBuilder` loop reverse 4s
    - When `MotionPreference.disabled(context)`: set `controller.value = 0`, do not `repeat`; for fallback, render static icon
    - Implement `WidgetsBindingObserver` to pause/resume on app lifecycle changes
    - Dispose controller and observer in `dispose()`
    - _Requirements: 10.1, 10.4, 10.5, 13.2, 14.2, 14.3, 14.4_

  - [ ]* 3.8 Write widget tests for new shared widgets
    - `ScanningBeam`: `active: false` → controller not animating; motion off + active → not animating; motion on + active → animating
    - `ShimmerSkeleton`: motion off → no `Shimmer` widget in tree; motion on → `Shimmer` present
    - `AnimatedNutritionBar`: motion off → final `valueRatio` at frame 0; motion on → intermediate value mid-tween
    - `VibrantBottomNav`: tap calls `onTap(index)`; motion off → indicator instantly at new position
    - `ConfettiBurst`: `play()` motion off → controller stays `stopped`, `HapticController` not called (verified via test mock)
    - `EmptyStateIllustration`: motion off → no `repeat`, frame at value 0
    - _Requirements: 4.1, 4.2, 6.1, 7.1, 7.5, 10.2, 10.5, 13.2_

- [x] 4. Checkpoint
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Wire screens with refreshed and new widgets
  - [x] 5.1 Create `lib/features/result/presentation/widgets/metric_max_reference.dart`
    - Define `MetricMaxReference` abstract final class with constants: `calories = 700.0`, `sugarGram = 25.0`, `sodiumMg = 1500.0`, `fatGram = 25.0`, `proteinGram = 30.0`, `carbsGram = 80.0`
    - Add `static double ratio(double value, double max) => (value / max).clamp(0.0, 1.0)`
    - _Requirements: 6.2_

  - [x] 5.2 Extract `lib/features/scan/presentation/scan_screen.dart` and refresh `lib/features/home/presentation/home_screen.dart`
    - Move scan UI (camera/gallery picker + `_ScanningState`) out of `_HomeDashboard` into a new `ScanScreen` widget
    - Inside `ScanScreen` loading state: render `Stack` with image preview + `ScanningBeam(active: state.isLoading)` overlay; for the result placeholder area below, render `ShimmerSkeleton.line/.box` composition (`ScanResultSkeleton`)
    - Tap handlers use refreshed `PulseIconButton` (haptic + tap-scale already wired); on success, call `HapticController.light()` then `Navigator.push(VibrantPageRoute(builder: (_) => ResultScreen(record: record)))`
    - On scan error/cancel (`state.errorMessage != null` or null record), show `SnackBar` with text `'Yah, gak jadi nih. Coba lagi ya 📸'` and ensure `ScanningBeam.active = false`
    - Wrap food image in `Hero(tag: 'food-image-${record.id}')` when a result is being navigated to
    - In `HomeScreen`: replace `BottomNavigationBar`/`NavigationBar` with `VibrantBottomNav`; replace inline scan dashboard with the new `ScanScreen` as the first tab page
    - In `_HeroHeader` and `_MiniLevelPill`: read colors from `colorScheme.primaryContainer` and `context.vibrantPalette.colorOf(level)` (no hardcoded color)
    - Add `Semantics(label: ...)` to icon-only buttons in scan flow (Bahasa Indonesia)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 5.1, 7.1, 7.4, 8.1, 11.1, 12.5, 13.5, 16.1, 16.2, 16.3, 16.4_

  - [x] 5.3 Refresh `lib/features/result/presentation/result_screen.dart` and result widgets
    - Wrap `_FoodImageHero` content in `Hero(tag: 'food-image-${record.id}')`
    - Replace fixed `_FoodImageHero` background `Color(0xFF111827)` with theme-driven gradient or `colorScheme.surfaceContainerHighest`
    - Build a `BadgeRevealHost` that hosts `FoodLevelBadge` and triggers `ConfettiBurstController.play()` on `addPostFrameCallback` after badge reveal completes when `level == NutritionLevel.a`
    - Replace metric `GridView.count` of `NutritionMetricTile` with composition using refreshed `nutrition_metric_tile.dart` that internally uses `AnimatedNutritionBar` + `MetricMaxReference.ratio(value, max)`; stagger delays at 80ms × index for the 5+ metrics
    - Refresh `prediction_confidence_list.dart` so each row uses staggered (60ms × index) `AnimatedNutritionBar`-style confidence bars over 500ms with `Curves.easeOutCubic`
    - Replace "Simpan ke History" `FilledButton.icon` with a version that swaps icon via `AnimatedSwitcher(duration: 250ms)` between `bookmark_outline` and `bookmark` on tap, plus `HapticController.light()`
    - Replace `Navigator.push(MaterialPageRoute(...NutriLevelGuideScreen...))` with `VibrantPageRoute(...)`
    - Wrap `ConfettiBurst` overlay in a top `Stack` layer
    - When `MotionPreference.disabled(context)`: skip confetti and stagger (final values rendered immediately by widgets)
    - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3, 6.5, 6.6, 6.7, 8.1, 10.2, 10.3, 11.1, 11.2, 11.3, 13.2, 13.3, 13.5, 14.5, 16.1_

  - [x] 5.4 Refresh `lib/features/history/presentation/history_screen.dart`
    - Replace `ListView` of records with `AnimatedList` so removal can use `SizeTransition` for collapse
    - Wrap each card in `SwipeToDeleteTile` (threshold 0.4); on confirmed dismiss call `historyController.removeRecord(record.id)` then show `SnackBar('Hasil scan dihapus')` with `UNDO` action active for 4s; UNDO restores via `historyController.restoreRecord(record)` (use existing controller method or temp local cache list)
    - Wrap each card image in `Hero(tag: 'food-image-${record.id}')` and use `VibrantPageRoute` to push `ResultScreen`
    - Replace summary header `Color(0xFF111827)` background with theme-driven primary container; use `TweenAnimationBuilder<double>` over 400ms to animate the "X hasil tersimpan" counter when `historyState.records.length` changes
    - Replace `FilterChip` with `_AnimatedFilterChip` that scale-tweens `Icons.check` `0 → 1` over 200ms `Curves.easeOutBack` when selected, plus `HapticController.selection()` on tap
    - Replace empty state with `EmptyStateIllustration(assetPath: 'assets/animations/empty_history.json', message: 'Yuk scan makanan pertama lo!')`
    - Wrap `ListView` with `RefreshIndicator` (custom child icon makanan rotating); pull threshold default ~80px
    - Add `Semantics(label: ...)` for swipe trash icon and chip selection
    - _Requirements: 5.1, 8.1, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 10.1, 10.4, 10.5, 11.2, 13.2, 13.5, 16.1, 16.3_

  - [x] 5.5 Refresh `lib/features/guide/presentation/nutri_level_guide_screen.dart`
    - Replace `_GuideHero` background `Color(0xFF4C1D95)` with `colorScheme.tertiaryContainer` (mustard turunan)
    - Pass `animateReveal: false` to `FoodLevelBadge` instances inside guide cards (panduan context, not reveal moment)
    - Verify all colors come from theme (no hardcoded color outside `vibrant_palette.dart`)
    - _Requirements: 1.6, 12.1, 12.2, 12.5_

  - [ ]* 5.6 Write screen integration tests
    - `result_screen_test.dart`: render with `NutritionLevel.a` → `ConfettiBurst` triggered; with `D` → confetti not triggered, shake active on badge; `Hero` with tag `food-image-${record.id}` present; motion off → all metric bars at final value at frame 0
    - `history_screen_test.dart`: swipe item past threshold → `onDelete` invoked, SnackBar with UNDO; tap UNDO → item restored; counter changes from N to N-1 show intermediate value mid-tween (motion on)
    - `scan_screen_test.dart`: `state.isLoading == true` → `ScanningBeam(active: true)` and `ShimmerSkeleton` in tree; `state.errorMessage != null` → SnackBar with text containing "gak jadi"; tap `PulseIconButton` → `HapticController.medium()` invoked (mock); successful scan pushes `VibrantPageRoute`
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 5.1, 6.5, 6.7, 9.1, 9.2, 9.3, 13.2, 13.3, 16.1_

- [ ] 6. Cross-cutting tests
  - [ ]* 6.1 Write `test/app/transitions/vibrant_page_route_test.dart`
    - Push route, mid-frame ∈ (0,1) `FadeTransition` opacity present
    - Motion off → only `FadeTransition` (no `SlideTransition`) and short duration
    - Pop route → reverse animation completes within 240ms
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [ ]* 6.2 Write `test/core/utils/haptic_controller_test.dart`
    - On `kIsWeb == true` (test override) → no `HapticFeedback` channel call (verify via `TestWidgetsFlutterBinding.defaultBinaryMessenger.setMockMethodCallHandler`)
    - On Android-simulated → `HapticFeedback.lightImpact` channel invoked
    - _Requirements: 11.4, 11.5_

  - [ ]* 6.3 Write golden tests in `test/golden/`
    - `food_level_badge_a_light.png`, `food_level_badge_d_light.png`, `food_level_badge_a_dark.png`, `food_level_badge_d_dark.png`
    - `vibrant_bottom_nav_selected_0.png`, `vibrant_bottom_nav_selected_2.png`
    - `scan_loading_skeleton_light.png`
    - `home_dashboard_light.png`, `home_dashboard_dark.png`
    - _Requirements: 1.1, 1.2, 1.6, 2.1, 2.3, 3.1, 7.1, 7.4, 12.5_

  - [ ]* 6.4 Write parameterized contrast/accessibility tests in `test/core/theme/contrast_test.dart`
    - For each `(NutritionLevel, Brightness)` combo, compute WCAG contrast ratio between `palette.colorOf(level)` and `palette.onColorOf(level)`; assert `≥ 4.5`
    - For both `Brightness.light` and `Brightness.dark`, assert contrast `(scheme.onSurface, scheme.surface) ≥ 4.5`
    - _Requirements: 1.5, 2.4, 3.3, 3.4, 13.6_

- [x] 7. Final checkpoint
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP path; the core implementation tasks (unmarked) deliver a working refreshed UI on their own.
- Each task references specific requirements clauses for traceability.
- The design explicitly states no Property-Based Testing for this UI feature; tests use widget tests, parameterized tests, golden tests, and mock-based unit tests.
- All animations honor `MotionPreference` from `MediaQuery.disableAnimations` as a first-class concern, never as a patch.
- Public API of the 5 existing shared widgets (`AnimatedEntry`, `PulseIconButton`, `SectionCard`, `SoftChip`, `FoodLevelBadge`) is preserved; only optional non-breaking named params are added.
- All animation controllers must be disposed in `State.dispose()` and lifecycle-aware loops must pause on `AppLifecycleState.paused`.
- No hardcoded `Color(0xFF...)` outside `lib/core/theme/vibrant_palette.dart`.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5", "2.4", "5.1"] },
    { "id": 1, "tasks": ["1.6", "1.8", "2.1", "3.1", "3.2", "3.3", "3.5", "3.7", "6.2"] },
    { "id": 2, "tasks": ["1.7", "1.9", "2.2", "2.3", "2.5", "3.4", "3.6", "6.1", "6.4"] },
    { "id": 3, "tasks": ["2.6", "3.8", "5.2", "5.3", "5.4", "5.5"] },
    { "id": 4, "tasks": ["5.6", "6.3"] }
  ]
}
```
