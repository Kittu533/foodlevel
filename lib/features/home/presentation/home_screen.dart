import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/vibrant_bottom_nav.dart';
import '../../guide/presentation/nutri_level_guide_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../scan/presentation/scan_screen.dart';

/// Root scaffold for the app.
///
/// Hosts three full-page tabs via [VibrantBottomNav]:
///   0 — [ScanScreen]            (scan flow + dashboard)
///   1 — [NutriLevelGuideScreen] (A-D guide)
///   2 — [HistoryScreen]         (scan history)
///
/// [VibrantBottomNav] provides spring-animated indicator, per-tab scale
/// micro-interactions, and haptic feedback (Requirements: 7.1, 7.2, 7.3, 7.4,
/// 7.5).
///
/// Requirements: 7.1, 7.4, 16.3, 16.4
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const _navItems = <BottomNavItem>[
    BottomNavItem(
      icon: Icons.document_scanner_outlined,
      selectedIcon: Icons.document_scanner,
      label: 'Scan',
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Guide',
    ),
    BottomNavItem(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Use IndexedStack to keep all pages alive (preserves state across tabs).
    const pages = [
      ScanScreen(),
      NutriLevelGuideScreen(),
      HistoryScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: VibrantBottomNav(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
