import '../../domain/issues/photo_check_result.dart';
import '../../domain/issues/photo_verdict.dart';
import 'evidence_item_dto.dart';

class PhotoCheckResultDto {
  final PhotoVerdict verdict;
  final double confidence;
  final List<EvidenceItemDto> evidence;
  final String aiSummary;

  const PhotoCheckResultDto({
    required this.verdict,
    required this.confidence,
    required this.evidence,
    required this.aiSummary,
  });

  factory PhotoCheckResultDto.fromDomain(PhotoCheckResult result) =>
      PhotoCheckResultDto(
        verdict: result.verdict,
        confidence: result.confidence,
        evidence: result.evidence
            .map(EvidenceItemDto.fromDomain)
            .toList(growable: false),
        aiSummary: result.aiSummary,
      );
}
