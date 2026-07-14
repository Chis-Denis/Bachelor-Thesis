import 'evidence_item.dart';
import 'photo_verdict.dart';

class PhotoCheckResult {
  final PhotoVerdict verdict;

  final double confidence;

  final List<EvidenceItem> evidence;

  final String aiSummary;

  const PhotoCheckResult({
    required this.verdict,
    required this.confidence,
    required this.evidence,
    required this.aiSummary,
  });
}
