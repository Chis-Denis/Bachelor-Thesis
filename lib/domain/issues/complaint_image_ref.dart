class ComplaintImageRef {
  ComplaintImageRef._();

  static const String _filePrefix = 'file:';
  static const String _assetPrefix = 'asset:';

  static String forFile(String absolutePath) => '$_filePrefix$absolutePath';

  static bool isFile(String ref) => ref.startsWith(_filePrefix);

  static String filePath(String ref) => ref.substring(_filePrefix.length);

  static String assetPath(String ref) =>
      ref.startsWith(_assetPrefix) ? ref.substring(_assetPrefix.length) : ref;
}
