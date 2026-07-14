import '../../domain/issues/issue.dart';
import '../../domain/issues/issue_status.dart';
import 'photo_check_result_dto.dart';

class IssueDto {
  final int id;
  final int restaurantId;
  final int? orderId;
  final String reporterUsername;
  final String description;
  final String imageRef;
  final DateTime createdAt;
  final IssueStatus status;
  final PhotoCheckResultDto? checkResult;

  const IssueDto({
    required this.id,
    required this.restaurantId,
    required this.orderId,
    required this.reporterUsername,
    required this.description,
    required this.imageRef,
    required this.createdAt,
    required this.status,
    required this.checkResult,
  });

  factory IssueDto.fromDomain(Issue issue) => IssueDto(
        id: issue.id,
        restaurantId: issue.restaurantId,
        orderId: issue.orderId,
        reporterUsername: issue.reporterUsername,
        description: issue.description,
        imageRef: issue.imageRef,
        createdAt: issue.createdAt,
        status: issue.status,
        checkResult: issue.checkResult == null
            ? null
            : PhotoCheckResultDto.fromDomain(issue.checkResult!),
      );
}
