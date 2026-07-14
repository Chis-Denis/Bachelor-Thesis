import 'issue_status.dart';
import 'photo_check_result.dart';

class Issue {
  final int id;
  final int restaurantId;
  final int? orderId;
  final int reporterUserId;
  final String reporterUsername;
  final String description;
  final String imageRef;
  final DateTime createdAt;
  final IssueStatus status;
  final PhotoCheckResult? checkResult;

  const Issue({
    required this.id,
    required this.restaurantId,
    required this.orderId,
    required this.reporterUserId,
    required this.reporterUsername,
    required this.description,
    required this.imageRef,
    required this.createdAt,
    required this.status,
    required this.checkResult,
  });
}
