import '../../domain/issues/issue_repository.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'issue_dto.dart';

class ListMyRestaurantIssues {
  final IssueRepository _issues;
  final RestaurantRepository _restaurants;
  final SessionStore _session;

  const ListMyRestaurantIssues(this._issues, this._restaurants, this._session);

  Future<OperationResult<List<IssueDto>>> call() async {
    try {
      final ownerId = _session.userId;
      if (ownerId == null) throw const NotAuthenticatedFailure();
      final restaurant = await _restaurants.findByOwner(ownerId);
      if (restaurant == null) return const OperationResult.ok([]);
      final issues = await _issues.findByRestaurant(restaurant.id);
      return OperationResult.ok(
        issues.map(IssueDto.fromDomain).toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load reports');
    }
  }
}
