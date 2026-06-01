import 'package:flutter/widgets.dart';

Widget buildImagePreview({
  required String path,
  required BoxFit fit,
  required Widget fallback,
}) {
  if (path.isEmpty) {
    return fallback;
  }

  return Image.network(path, fit: fit, errorBuilder: (_, _, _) => fallback);
}
