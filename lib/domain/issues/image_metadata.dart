class ImageMetadata {
  final String format;
  final bool hasExif;
  final String? cameraMake;
  final String? cameraModel;
  final String? dateTimeOriginal;
  final String? software;
  final bool hasC2pa;
  final String? c2paGenerator;

  const ImageMetadata({
    required this.format,
    required this.hasExif,
    this.cameraMake,
    this.cameraModel,
    this.dateTimeOriginal,
    this.software,
    required this.hasC2pa,
    this.c2paGenerator,
  });

  bool get hasCameraSignature => cameraMake != null || cameraModel != null;

  String get cameraLabel =>
      [cameraMake, cameraModel].where((v) => v != null).join(' ').trim();
}
