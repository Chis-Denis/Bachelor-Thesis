import 'dart:convert';

import '../../domain/issues/evidence_item.dart';
import '../../domain/issues/issue.dart';
import '../../domain/issues/issue_draft.dart';
import '../../domain/issues/issue_status.dart';
import '../../domain/issues/photo_check_result.dart';
import '../../domain/issues/photo_verdict.dart';
import '../../domain/issues/issue_repository.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteIssueRepository implements IssueRepository {
  final SqfliteUnitOfWork _work;

  SqfliteIssueRepository(this._work);

  @override
  Future<int> create({
    required int reporterUserId,
    required String reporterUsername,
    required IssueDraft draft,
  }) async {
    final db = await _work.executor();
    return db.insert(IssuesTable.name, {
      IssuesTable.restaurantId: draft.restaurantId,
      IssuesTable.orderId: draft.orderId,
      IssuesTable.reporterUserId: reporterUserId,
      IssuesTable.reporterUsername: reporterUsername,
      IssuesTable.description: draft.description,
      IssuesTable.imageRef: draft.imageRef,
      IssuesTable.createdAt: DateTime.now().millisecondsSinceEpoch,
      IssuesTable.status: IssueStatus.open.name,
    });
  }

  @override
  Future<List<Issue>> findByRestaurant(int restaurantId) async {
    final db = await _work.executor();
    final rows = await db.query(
      IssuesTable.name,
      where: '${IssuesTable.restaurantId} = ?',
      whereArgs: [restaurantId],
      orderBy: '${IssuesTable.createdAt} DESC',
    );
    return rows.map(_issueFromRow).toList(growable: false);
  }

  @override
  Future<Issue?> findById(int issueId) async {
    final db = await _work.executor();
    final rows = await db.query(
      IssuesTable.name,
      where: '${IssuesTable.id} = ?',
      whereArgs: [issueId],
      limit: 1,
    );
    return rows.isEmpty ? null : _issueFromRow(rows.first);
  }

  @override
  Future<void> saveCheckResult(int issueId, PhotoCheckResult result) async {
    final db = await _work.executor();
    await db.update(
      IssuesTable.name,
      {
        IssuesTable.status: IssueStatus.reviewed.name,
        IssuesTable.verdict: result.verdict.name,
        IssuesTable.confidence: result.confidence,
        IssuesTable.evidenceJson: _encodeEvidence(result.evidence),
        IssuesTable.aiSummary: result.aiSummary,
      },
      where: '${IssuesTable.id} = ?',
      whereArgs: [issueId],
    );
  }

  Issue _issueFromRow(Map<String, Object?> row) {
    final verdictName = row[IssuesTable.verdict] as String?;
    final checkResult = verdictName == null
        ? null
        : PhotoCheckResult(
            verdict: PhotoVerdict.values.byName(verdictName),
            confidence: (row[IssuesTable.confidence] as num?)?.toDouble() ?? 0,
            evidence: _decodeEvidence(row[IssuesTable.evidenceJson] as String?),
            aiSummary: (row[IssuesTable.aiSummary] as String?) ?? '',
          );

    return Issue(
      id: (row[IssuesTable.id] as num).toInt(),
      restaurantId: (row[IssuesTable.restaurantId] as num).toInt(),
      orderId: (row[IssuesTable.orderId] as num?)?.toInt(),
      reporterUserId: (row[IssuesTable.reporterUserId] as num).toInt(),
      reporterUsername: row[IssuesTable.reporterUsername] as String,
      description: (row[IssuesTable.description] as String?) ?? '',
      imageRef: row[IssuesTable.imageRef] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          row[IssuesTable.createdAt] as int),
      status: IssueStatus.values.byName(
          (row[IssuesTable.status] as String?) ?? IssueStatus.open.name),
      checkResult: checkResult,
    );
  }

  String _encodeEvidence(List<EvidenceItem> items) => json.encode([
        for (final item in items)
          {
            'label': item.label,
            'detail': item.detail,
            'signal': item.signal.name,
          },
      ]);

  List<EvidenceItem> _decodeEvidence(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final list = json.decode(raw) as List;
    return [
      for (final entry in list.whereType<Map<String, Object?>>())
        EvidenceItem(
          label: entry['label'] as String? ?? '',
          detail: entry['detail'] as String? ?? '',
          signal: EvidenceSignal.values.byName(
              entry['signal'] as String? ?? EvidenceSignal.neutral.name),
        ),
    ];
  }
}
