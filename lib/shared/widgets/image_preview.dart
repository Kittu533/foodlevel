import 'package:flutter/widgets.dart';

import 'image_preview_stub.dart'
    if (dart.library.io) 'image_preview_io.dart'
    if (dart.library.html) 'image_preview_web.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    required this.path,
    required this.fallback,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return buildImagePreview(path: path, fit: fit, fallback: fallback);
  }
}
