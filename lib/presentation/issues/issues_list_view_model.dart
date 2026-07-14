import '../../application/issues/issue_dto.dart';
import '../../application/issues/list_my_restaurant_issues.dart';
import '../common/view_model.dart';

class IssuesListViewModel extends ViewModel {
  final ListMyRestaurantIssues _list;

  bool isLoading = true;
  String? errorMessage;
  List<IssueDto> issues = const [];

  IssuesListViewModel(this._list);

  Future<void> load() async {
    isLoading = true;
    notify();
    final result = await _list();
    if (result.isSuccess) {
      issues = result.data ?? const [];
    } else {
      errorMessage = result.error;
    }
    isLoading = false;
    notify();
  }

  void clearError() => errorMessage = null;
}
