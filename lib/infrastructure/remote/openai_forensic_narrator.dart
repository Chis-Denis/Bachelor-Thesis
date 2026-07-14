import 'dart:convert';

import '../../domain/constants/openai_constants.dart';
import '../../domain/issues/forensic_assessment.dart';
import '../../domain/issues/forensic_narrator.dart';
import '../../domain/shared/failures.dart';
import '../../domain/suggestions/stable_hash.dart';
import 'openai_client.dart';

class OpenAiForensicNarrator implements ForensicNarrator {
  final OpenAiClient _client;

  const OpenAiForensicNarrator(this._client);

  static const int _maxTokens = 200;

  @override
  Future<String> summarise(ForensicAssessment assessment) async {
    final findings = _findingsText(assessment);
    final response = await _client.createChatCompletion(_body(findings));
    return _extract(response);
  }

  String _findingsText(ForensicAssessment assessment) {
    final evidence = assessment.evidence
        .map((item) => '- ${item.label}: ${item.detail}')
        .join('\n');
    return 'Automated forensic verdict: ${assessment.verdict.label} '
        '(${(assessment.confidence * 100).round()}% confidence).\n'
        'Metadata findings:\n$evidence';
  }

  Map<String, Object?> _body(String findings) => {
        'model': OpenAiConstants.model,
        'temperature': OpenAiConstants.temperature,
        'max_tokens': _maxTokens,
        'seed': StableHash.fnv1a(findings),
        'response_format': _responseFormat(),
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': findings},
        ],
      };

  static const String _systemPrompt =
      'You assist a restaurant owner who is reviewing a customer complaint '
      'photo. You are given ONLY the results of an automated, deterministic '
      'analysis of the photo file\'s metadata — you do NOT see the image. In one '
      'or two plain sentences, explain what the findings mean for the '
      'credibility of the complaint and give a brief recommendation. Base '
      'everything strictly on the findings and never claim to have seen the '
      'image.';

  Map<String, Object?> _responseFormat() => {
        'type': 'json_schema',
        'json_schema': {
          'name': 'forensic_recommendation',
          'strict': true,
          'schema': {
            'type': 'object',
            'properties': {
              'summary': {'type': 'string'},
            },
            'required': ['summary'],
            'additionalProperties': false,
          },
        },
      };

  String _extract(Map<String, Object?> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const SuggestionFailure('OpenAI returned no choices.');
    }
    final message = (choices.first as Map)['message'];
    final content = message is Map ? message['content'] : null;
    if (content is! String || content.isEmpty) {
      throw const SuggestionFailure('OpenAI returned an empty response.');
    }
    final decoded = json.decode(content);
    final summary = decoded is Map<String, Object?> ? decoded['summary'] : null;
    if (summary is! String || summary.trim().isEmpty) {
      throw const SuggestionFailure('Malformed recommendation.');
    }
    return summary.trim();
  }
}
