import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Cross-platform haptic wrapper.
///
/// Call-sites do not need to guard with `if (kIsWeb)` — this class handles
/// platform detection internally (Requirement 11.4, 11.5).
///
/// On web and desktop the methods are no-ops that return [Future.value()].
/// On Android / iOS they delegate to the corresponding [HapticFeedback] call.
abstract final class HapticController {
  /// Returns `true` only on Android and iOS (non-web).
  static bool get _enabled =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Triggers [HapticFeedback.lightImpact] on mobile; no-op elsewhere.
  static Future<void> light() =>
      _enabled ? HapticFeedback.lightImpact() : Future.value();

  /// Triggers [HapticFeedback.mediumImpact] on mobile; no-op elsewhere.
  static Future<void> medium() =>
      _enabled ? HapticFeedback.mediumImpact() : Future.value();

  /// Triggers [HapticFeedback.heavyImpact] on mobile; no-op elsewhere.
  static Future<void> heavy() =>
      _enabled ? HapticFeedback.heavyImpact() : Future.value();

  /// Triggers [HapticFeedback.selectionClick] on mobile; no-op elsewhere.
  static Future<void> selection() =>
      _enabled ? HapticFeedback.selectionClick() : Future.value();
}
