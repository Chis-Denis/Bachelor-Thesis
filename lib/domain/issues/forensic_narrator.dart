import 'forensic_assessment.dart';

abstract interface class ForensicNarrator {
  Future<String> summarise(ForensicAssessment assessment);
}
