import '../../domain/issues/issue_draft.dart';
import '../../domain/issues/issue_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';

class ReportIssue {
  final IssueRepository _repository;
  final SessionStore _session;

  const ReportIssue(this._repository, this._session);

  Future<OperationResult<void>> call({
    required int restaurantId,
    int? orderId,
    required String description,
    required String imageRef,
  }) async {
    try {
      final user = _session.current;
      if (user == null) throw const NotAuthenticatedFailure();
      if (imageRef.trim().isEmpty) {
        throw const ValidationFailure('Attach a photo of the problem');
      }
      await _repository.create(
        reporterUserId: user.id,
        reporterUsername: user.username,
        draft: IssueDraft(
          restaurantId: restaurantId,
          orderId: orderId,
          description: description.trim(),
          imageRef: imageRef,
        ),
      );
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not submit your report');
    }
  }
}
