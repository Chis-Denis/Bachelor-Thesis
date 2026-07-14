import 'issue.dart';
import 'issue_draft.dart';
import 'photo_check_result.dart';

abstract interface class IssueRepository {
  Future<int> create({
    required int reporterUserId,
    required String reporterUsername,
    required IssueDraft draft,
  });

  Future<List<Issue>> findByRestaurant(int restaurantId);

  Future<Issue?> findById(int issueId);

  Future<void> saveCheckResult(int issueId, PhotoCheckResult result);
}
