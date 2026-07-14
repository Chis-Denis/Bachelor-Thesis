import 'evidence_item.dart';
import 'photo_verdict.dart';

class ForensicAssessment {
  final PhotoVerdict verdict;
  final double confidence;
  final List<EvidenceItem> evidence;

  const ForensicAssessment({
    required this.verdict,
    required this.confidence,
    required this.evidence,
  });
}
