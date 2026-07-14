import 'dart:typed_data';

import 'package:exif/exif.dart';

import '../../domain/issues/image_metadata.dart';
import '../../domain/issues/image_metadata_reader.dart';

class ImageMetadataParser implements ImageMetadataReader {
  const ImageMetadataParser();

  static const int _scanLimit = 262144;

  @override
  Future<ImageMetadata> read(Uint8List bytes) async {
    final scanText = _scanText(bytes);
    final hasC2pa = scanText.contains('jumb') || scanText.contains('c2pa');

    final tags = await readExifFromBytes(bytes);
    String? read(String key) {
      final value = tags[key]?.printable.trim();
      return (value == null || value.isEmpty) ? null : value;
    }

    final make = read('Image Make');
    final model = read('Image Model');
    final software = read('Image Software');
    final dateTimeOriginal =
        read('EXIF DateTimeOriginal') ?? read('Image DateTime');

    return ImageMetadata(
      format: _format(bytes),
      hasExif: tags.isNotEmpty,
      cameraMake: make,
      cameraModel: model,
      dateTimeOriginal: dateTimeOriginal,
      software: software,
      hasC2pa: hasC2pa,
      c2paGenerator: hasC2pa ? _findGenerator(scanText) : null,
    );
  }

  String _format(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'jpeg';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    return 'unknown';
  }

  String _scanText(Uint8List bytes) {
    final limit = bytes.length < _scanLimit ? bytes.length : _scanLimit;
    return String.fromCharCodes(bytes, 0, limit).toLowerCase();
  }

  String? _findGenerator(String scanText) {
    const generators = [
      'dall-e',
      'midjourney',
      'stable diffusion',
      'firefly',
      'imagen',
      'openai',
    ];
    for (final generator in generators) {
      if (scanText.contains(generator)) return generator;
    }
    return null;
  }
}
