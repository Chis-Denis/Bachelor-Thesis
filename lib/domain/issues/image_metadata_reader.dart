import 'dart:typed_data';

import 'image_metadata.dart';

abstract interface class ImageMetadataReader {
  Future<ImageMetadata> read(Uint8List bytes);
}
