import 'package:flutter/material.dart';
import 'package:foodlevel/core/theme/animation_budget.dart';

/// A swipe-to-delete wrapper that wraps [child] in a [Dismissible] widget
/// configured for end-to-start (left swipe) deletion.
///
/// The secondary background reveals a terracotta-tinted container
/// ([ColorScheme.errorContainer]) with a trash icon. The icon appears at
/// full opacity as the reveal naturally transitions with the swipe gesture.
///
/// On confirmed dismiss, [onDelete] is called. The caller (typically an
/// [AnimatedList] in `HistoryScreen`) is responsible for collapsing the
/// item with a [SizeTransition] over [AnimationBudget.swipeCollapse].
///
/// Requirements: 9.1, 9.2
class SwipeToDeleteTile extends StatelessWidget {
  const SwipeToDeleteTile({
    required this.itemKey,
    required this.child,
    required this.onDelete,
    this.threshold = 0.4,
    super.key,
  });

  /// The unique [Key] passed to the underlying [Dismissible]. Must be unique
  /// within the list to prevent Flutter from re-using dismissed tiles.
  final Key itemKey;

  /// The list tile or card content to display.
  final Widget child;

  /// Callback invoked when the user swipes past [threshold]. Return `true` to
  /// confirm deletion, `false` to cancel and snap the tile back.
  final Future<bool> Function() onDelete;

  /// Fraction of the item width that must be swiped before dismissal is
  /// confirmed. Defaults to 0.4 (40 %) per Requirement 9.1.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      dismissThresholds: {
        DismissDirection.endToStart: threshold,
      },
      // The background shown as the tile is swiped from end to start.
      // Uses colorScheme.errorContainer (terracotta-derived) with a centered
      // trash icon for a visually clear delete affordance (Requirement 9.1).
      secondaryBackground: _DeleteBackground(colorScheme: colorScheme),
      confirmDismiss: (_) => onDelete(),
      // Collapse animation is delegated to the outer AnimatedList /
      // SizeTransition (Requirement 9.2). The Dismissible handles the
      // horizontal slide-out; the vertical collapse happens in the list.
      resizeDuration: AnimationBudget.swipeCollapse,
      child: child,
    );
  }
}

/// The red/terracotta background shown behind the sliding tile.
///
/// Displays [colorScheme.errorContainer] fill with a centred/right-aligned
/// trash icon. Wrapped in a [Semantics] node so screen-reader users know the
/// swipe gesture deletes the item (Requirement 13.5).
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Hapus hasil scan',
      child: Container(
        alignment: Alignment.centerRight,
        color: colorScheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onErrorContainer,
          size: 28,
          semanticLabel: 'Hapus',
        ),
      ),
    );
  }
}
