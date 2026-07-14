import 'dart:io';

import 'package:flutter/services.dart';

import '../../domain/issues/complaint_image_ref.dart';
import '../../domain/issues/complaint_image_store.dart';

class AssetComplaintImageStore implements ComplaintImageStore {
  const AssetComplaintImageStore();

  static const Map<String, String> _images = {
    'assets/demo_complaints/burger.jpg': 'Burger',
    'assets/demo_complaints/pizza1.jpg': 'Pizza',
    'assets/demo_complaints/pizza2.jpg': 'Pizza slice',
    'assets/demo_complaints/burgerAi.png': 'Burger (B)',
    'assets/demo_complaints/pizzaAi.png': 'Pizza (B)',
  };

  @override
  List<String> get demoImageRefs => _images.keys.toList(growable: false);

  @override
  String labelFor(String imageRef) => _images[imageRef] ?? 'Photo';

  @override
  Future<Uint8List> load(String imageRef) async {
    if (ComplaintImageRef.isFile(imageRef)) {
      return File(ComplaintImageRef.filePath(imageRef)).readAsBytes();
    }
    final data = await rootBundle.load(ComplaintImageRef.assetPath(imageRef));
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
