import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shows a photo stored on the device file system: Image.file(File(path)).
/// (On Flutter Web there is no file system, so the browser URL is used.)
class DiaryImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Decode at this width only -> small thumbnails do not eat memory.
  final int? cacheWidth;

  const DiaryImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  Widget _broken(BuildContext context) => Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.broken_image_outlined,
            color: Theme.of(context).hintColor),
      );

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (c, e, s) => _broken(c));
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (c, e, s) => _broken(c),
    );
  }
}
