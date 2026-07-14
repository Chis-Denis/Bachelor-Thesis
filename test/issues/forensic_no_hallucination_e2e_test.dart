import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/application/issues/check_issue_photo.dart';
import 'package:calorietrack_flutter/domain/constants/photo_check_constants.dart';
import 'package:calorietrack_flutter/domain/issues/complaint_image_store.dart';
import 'package:calorietrack_flutter/domain/issues/forensic_evaluator.dart';
import 'package:calorietrack_flutter/domain/issues/issue.dart';
import 'package:calorietrack_flutter/domain/issues/issue_repository.dart';
import 'package:calorietrack_flutter/domain/issues/issue_status.dart';
import 'package:calorietrack_flutter/domain/issues/photo_check_result.dart';
import 'package:calorietrack_flutter/domain/issues/photo_verdict.dart';
import 'package:calorietrack_flutter/infrastructure/forensics/image_metadata_parser.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_forensic_narrator.dart';

import '../helpers/fakes.dart';

void main() {
  Future<Uint8List> bytesOf(String name) =>
      File('assets/demo_complaints/$name').readAsBytes();

  CheckIssuePhoto checkFor(
    _FakeIssueRepo repo,
    Uint8List bytes,
    RecordingOpenAi ai,
  ) =>
      CheckIssuePhoto(
        repo,
        _FakeImageStore(bytes),
        const ImageMetadataParser(),
        const ForensicEvaluator(),
        OpenAiForensicNarrator(ai.client),
      );

  test(
      'the verdict is computed locally and is identical whatever the model says',
      () async {
    final aiBytes = await bytesOf('burgerAi.png');

    final firstAi = RecordingOpenAi(
        (_) => json.encode({'summary': 'This looks fabricated.'}));
    final first = await checkFor(_FakeIssueRepo(), aiBytes, firstAi).call(1);

    final secondAi = RecordingOpenAi((_) => json
        .encode({'summary': 'A completely different, contradictory take.'}));
    final second = await checkFor(_FakeIssueRepo(), aiBytes, secondAi).call(1);

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);

    expect(first.data!.verdict, PhotoVerdict.likelyAiGenerated);
    expect(first.data!.confidence, PhotoCheckConstants.c2paConfidence);
    expect(second.data!.verdict, first.data!.verdict);
    expect(second.data!.confidence, first.data!.confidence);

    expect(first.data!.aiSummary, isNot(equals(second.data!.aiSummary)));
  });

  test(
      'the model request never carries the image bytes, only the findings text',
      () async {
    final aiBytes = await bytesOf('burgerAi.png');
    final ai = RecordingOpenAi((_) => json.encode({'summary': 'ok'}));

    await checkFor(_FakeIssueRepo(), aiBytes, ai).call(1);

    expect(ai.bodies, hasLength(1));
    final encoded = json.encode(ai.bodies.single);

    expect(encoded.contains(base64Encode(aiBytes)), isFalse);
    expect(encoded.length, lessThan(aiBytes.length));

    final messages =
        (ai.bodies.single['messages'] as List).cast<Map<String, Object?>>();
    final userContent = messages.last['content'] as String;
    expect(userContent, contains('Likely AI-generated'));
    expect(userContent, contains('Metadata findings'));
  });

  test('a failing model leaves the deterministic verdict and a local fallback',
      () async {
    final aiBytes = await bytesOf('burgerAi.png');
    final ai = RecordingOpenAi((_) => '{"unexpected": true}');
    final repo = _FakeIssueRepo();

    final result = await checkFor(repo, aiBytes, ai).call(1);

    expect(result.isSuccess, isTrue);
    expect(result.data!.verdict, PhotoVerdict.likelyAiGenerated);
    expect(result.data!.confidence, PhotoCheckConstants.c2paConfidence);
    expect(result.data!.aiSummary, contains('AI content credentials'));

    expect(repo.saved, isNotNull);
    expect(repo.saved!.verdict, PhotoVerdict.likelyAiGenerated);
  });

  test(
      'a metadata-stripped photo yields a stable inconclusive verdict, not genuine',
      () async {
    final realBytes = await bytesOf('burger.jpg');
    final ai =
        RecordingOpenAi((_) => json.encode({'summary': 'Cannot verify.'}));

    final result = await checkFor(_FakeIssueRepo(), realBytes, ai).call(1);

    expect(result.data!.verdict, PhotoVerdict.inconclusive);
    expect(result.data!.confidence, PhotoCheckConstants.inconclusiveConfidence);
  });
}

class _FakeImageStore implements ComplaintImageStore {
  final Uint8List _bytes;

  _FakeImageStore(this._bytes);

  @override
  Future<Uint8List> load(String imageRef) async => _bytes;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeIssueRepo implements IssueRepository {
  PhotoCheckResult? saved;

  @override
  Future<Issue?> findById(int issueId) async => Issue(
        id: issueId,
        restaurantId: 1,
        orderId: null,
        reporterUserId: 2,
        reporterUsername: 'customer',
        description: 'The pizza was burnt',
        imageRef: 'demo',
        createdAt: DateTime(2026, 6, 12),
        status: IssueStatus.open,
        checkResult: null,
      );

  @override
  Future<void> saveCheckResult(int issueId, PhotoCheckResult result) async {
    saved = result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
