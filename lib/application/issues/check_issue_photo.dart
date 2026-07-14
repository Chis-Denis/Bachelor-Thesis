import '../../domain/issues/complaint_image_store.dart';
import '../../domain/issues/forensic_assessment.dart';
import '../../domain/issues/forensic_evaluator.dart';
import '../../domain/issues/forensic_narrator.dart';
import '../../domain/issues/image_metadata_reader.dart';
import '../../domain/issues/issue_repository.dart';
import '../../domain/issues/photo_check_result.dart';
import '../../domain/issues/photo_verdict.dart';
import '../../domain/shared/failures.dart';
import '../shared/operation_result.dart';
import 'photo_check_result_dto.dart';

class CheckIssuePhoto {
  final IssueRepository _issues;
  final ComplaintImageStore _images;
  final ImageMetadataReader _metadataReader;
  final ForensicEvaluator _forensic;
  final ForensicNarrator _narrator;

  const CheckIssuePhoto(
    this._issues,
    this._images,
    this._metadataReader,
    this._forensic,
    this._narrator,
  );

  Future<OperationResult<PhotoCheckResultDto>> call(int issueId) async {
    try {
      final issue = await _issues.findById(issueId);
      if (issue == null) return const OperationResult.fail('Report not found');

      final bytes = await _images.load(issue.imageRef);
      final metadata = await _metadataReader.read(bytes);
      final assessment = _forensic.evaluate(metadata);

      final result = PhotoCheckResult(
        verdict: assessment.verdict,
        confidence: assessment.confidence,
        evidence: assessment.evidence,
        aiSummary: await _summarise(assessment),
      );

      await _issues.saveCheckResult(issueId, result);
      return OperationResult.ok(PhotoCheckResultDto.fromDomain(result));
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not analyse the photo');
    }
  }

  Future<String> _summarise(ForensicAssessment assessment) async {
    try {
      return await _narrator.summarise(assessment);
    } catch (_) {
      return _fallbackSummary(assessment.verdict);
    }
  }

  String _fallbackSummary(PhotoVerdict verdict) => switch (verdict) {
        PhotoVerdict.likelyGenuine =>
          'The file metadata is consistent with a genuine camera photo.',
        PhotoVerdict.possiblyEdited =>
          'The metadata shows the image passed through photo-editing software.',
        PhotoVerdict.likelyAiGenerated =>
          'The file carries AI content credentials, indicating it was generated.',
        PhotoVerdict.inconclusive =>
          'No conclusive metadata was found; the photo cannot be verified either way.',
      };
}
