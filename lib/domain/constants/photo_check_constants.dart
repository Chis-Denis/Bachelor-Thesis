class PhotoCheckConstants {
  PhotoCheckConstants._();

  static const double c2paConfidence = 0.95;
  static const double editedConfidence = 0.8;
  static const double genuineStrongConfidence = 0.85;
  static const double genuineWeakConfidence = 0.6;
  static const double inconclusiveConfidence = 0.4;

  static const Set<String> editorSoftwareKeywords = {
    'photoshop',
    'lightroom',
    'gimp',
    'affinity',
    'pixelmator',
    'snapseed',
    'facetune',
    'picsart',
    'paint.net',
    'capture one',
  };

  static const Set<String> aiGeneratorKeywords = {
    'dall-e',
    'dall·e',
    'dalle',
    'midjourney',
    'stable diffusion',
    'firefly',
    'imagen',
    'gemini',
    'openai',
    'gpt-4o',
  };
}
