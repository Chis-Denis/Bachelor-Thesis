import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/issues/complaint_image_ref.dart';
import '../design/design.dart';

class ComplaintImage extends StatelessWidget {
  final String imageRef;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ComplaintImage({
    super.key,
    required this.imageRef,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (ComplaintImageRef.isFile(imageRef)) {
      return Image.file(
        File(ComplaintImageRef.filePath(imageRef)),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: _placeholder,
      );
    }
    return Image.asset(
      ComplaintImageRef.assetPath(imageRef),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _placeholder,
    );
  }

  Widget _placeholder(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child:
          const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
    );
  }
}
