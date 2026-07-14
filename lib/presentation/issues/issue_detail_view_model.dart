import '../../application/issues/check_issue_photo.dart';
import '../../application/issues/issue_dto.dart';
import '../../application/issues/photo_check_result_dto.dart';
import '../common/view_model.dart';

class IssueDetailViewModel extends ViewModel {
  final CheckIssuePhoto _check;
  final IssueDto issue;

  bool isChecking = false;
  String? errorMessage;
  PhotoCheckResultDto? result;

  IssueDetailViewModel(this._check, this.issue) : result = issue.checkResult;

  Future<void> runCheck() async {
    isChecking = true;
    errorMessage = null;
    notify();
    final outcome = await _check(issue.id);
    if (outcome.isSuccess) {
      result = outcome.data;
    } else {
      errorMessage = outcome.error;
    }
    isChecking = false;
    notify();
  }

  void clearError() => errorMessage = null;
}
