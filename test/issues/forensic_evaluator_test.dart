import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/constants/photo_check_constants.dart';
import 'package:calorietrack_flutter/domain/issues/forensic_evaluator.dart';
import 'package:calorietrack_flutter/domain/issues/image_metadata.dart';
import 'package:calorietrack_flutter/domain/issues/photo_verdict.dart';

ImageMetadata metadata({
  String format = 'jpeg',
  bool hasExif = false,
  String? cameraMake,
  String? cameraModel,
  String? dateTimeOriginal,
  String? software,
  bool hasC2pa = false,
  String? c2paGenerator,
}) {
  return ImageMetadata(
    format: format,
    hasExif: hasExif,
    cameraMake: cameraMake,
    cameraModel: cameraModel,
    dateTimeOriginal: dateTimeOriginal,
    software: software,
    hasC2pa: hasC2pa,
    c2paGenerator: c2paGenerator,
  );
}

void main() {
  const evaluator = ForensicEvaluator();

  group('ForensicEvaluator', () {
    test('a C2PA credential yields a high-confidence AI verdict', () {
      final result = evaluator.evaluate(
        metadata(format: 'png', hasC2pa: true, c2paGenerator: 'Adobe Firefly'),
      );
      expect(result.verdict, PhotoVerdict.likelyAiGenerated);
      expect(result.confidence, PhotoCheckConstants.c2paConfidence);
      expect(result.confidence, 0.95);
    });

    test('an AI generator software tag is treated as AI-generated', () {
      final result =
          evaluator.evaluate(metadata(hasExif: true, software: 'DALL-E'));
      expect(result.verdict, PhotoVerdict.likelyAiGenerated);
    });

    test('an editor software tag is treated as possibly edited', () {
      final result = evaluator.evaluate(
        metadata(hasExif: true, software: 'Adobe Photoshop 25.0'),
      );
      expect(result.verdict, PhotoVerdict.possiblyEdited);
      expect(result.confidence, PhotoCheckConstants.editedConfidence);
    });

    test('a camera make and model with a date is likely genuine (strong)', () {
      final result = evaluator.evaluate(metadata(
        hasExif: true,
        cameraMake: 'Apple',
        cameraModel: 'iPhone 13',
        dateTimeOriginal: '2024:05:01 12:00:00',
      ));
      expect(result.verdict, PhotoVerdict.likelyGenuine);
      expect(result.confidence, PhotoCheckConstants.genuineStrongConfidence);
    });

    test('a camera signature without a date is likely genuine (weak)', () {
      final result = evaluator.evaluate(
        metadata(hasExif: true, cameraMake: 'Samsung', cameraModel: 'SM-G991B'),
      );
      expect(result.verdict, PhotoVerdict.likelyGenuine);
      expect(result.confidence, PhotoCheckConstants.genuineWeakConfidence);
    });

    test('a metadata-stripped file is inconclusive, not genuine', () {
      final result = evaluator.evaluate(metadata());
      expect(result.verdict, PhotoVerdict.inconclusive);
      expect(result.confidence, 0.4);
    });

    test('the same metadata always yields an identical assessment', () {
      final input = metadata(hasC2pa: true, c2paGenerator: 'Midjourney');
      final a = evaluator.evaluate(input);
      final b = evaluator.evaluate(input);
      expect(a.verdict, b.verdict);
      expect(a.confidence, b.confidence);
      expect(a.evidence.length, b.evidence.length);
    });
  });
}
