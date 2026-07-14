import '../constants/photo_check_constants.dart';
import 'evidence_item.dart';
import 'forensic_assessment.dart';
import 'image_metadata.dart';
import 'photo_verdict.dart';

class ForensicEvaluator {
  const ForensicEvaluator();

  ForensicAssessment evaluate(ImageMetadata metadata) {
    final evidence = <EvidenceItem>[];

    if (metadata.hasC2pa) {
      final generator = metadata.c2paGenerator;
      evidence.add(EvidenceItem(
        label: 'AI content credentials (C2PA) found',
        detail: generator == null
            ? 'The file embeds a provenance manifest typical of AI generators.'
            : 'Provenance manifest names the generator "$generator".',
        signal: EvidenceSignal.supportsManipulation,
      ));
      return ForensicAssessment(
        verdict: PhotoVerdict.likelyAiGenerated,
        confidence: PhotoCheckConstants.c2paConfidence,
        evidence: evidence,
      );
    }

    final software = metadata.software;
    if (software != null &&
        _matches(software, PhotoCheckConstants.aiGeneratorKeywords)) {
      evidence.add(EvidenceItem(
        label: 'AI generator tag in metadata',
        detail: 'The software field reads "$software".',
        signal: EvidenceSignal.supportsManipulation,
      ));
      return ForensicAssessment(
        verdict: PhotoVerdict.likelyAiGenerated,
        confidence: PhotoCheckConstants.c2paConfidence,
        evidence: evidence,
      );
    }

    if (software != null &&
        _matches(software, PhotoCheckConstants.editorSoftwareKeywords)) {
      evidence.add(EvidenceItem(
        label: 'Editing software tag',
        detail: 'The image was saved by "$software".',
        signal: EvidenceSignal.supportsManipulation,
      ));
      return ForensicAssessment(
        verdict: PhotoVerdict.possiblyEdited,
        confidence: PhotoCheckConstants.editedConfidence,
        evidence: evidence,
      );
    }

    if (metadata.hasCameraSignature) {
      final hasDate = metadata.dateTimeOriginal != null;
      evidence.add(EvidenceItem(
        label: 'Camera metadata present',
        detail: hasDate
            ? 'Captured on ${metadata.cameraLabel}, taken ${metadata.dateTimeOriginal}.'
            : 'Captured on ${metadata.cameraLabel}.',
        signal: EvidenceSignal.supportsGenuine,
      ));
      return ForensicAssessment(
        verdict: PhotoVerdict.likelyGenuine,
        confidence: hasDate
            ? PhotoCheckConstants.genuineStrongConfidence
            : PhotoCheckConstants.genuineWeakConfidence,
        evidence: evidence,
      );
    }

    evidence.add(const EvidenceItem(
      label: 'No camera metadata',
      detail: 'No camera make/model or capture date — common for screenshots, '
          'downloads and AI-generated images.',
      signal: EvidenceSignal.neutral,
    ));
    return ForensicAssessment(
      verdict: PhotoVerdict.inconclusive,
      confidence: PhotoCheckConstants.inconclusiveConfidence,
      evidence: evidence,
    );
  }

  bool _matches(String value, Set<String> keywords) {
    final lower = value.toLowerCase();
    return keywords.any(lower.contains);
  }
}
