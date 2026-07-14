import 'package:flutter/material.dart';

import '../../domain/issues/evidence_item.dart';
import '../../domain/issues/photo_verdict.dart';
import '../design/design.dart';

class VerdictVisuals {
  VerdictVisuals._();

  static Color color(PhotoVerdict verdict) => switch (verdict) {
        PhotoVerdict.likelyGenuine => const Color(0xFF16A34A),
        PhotoVerdict.possiblyEdited => const Color(0xFFF59E0B),
        PhotoVerdict.likelyAiGenerated => const Color(0xFFDC2626),
        PhotoVerdict.inconclusive => AppColors.textSecondary,
      };

  static IconData icon(PhotoVerdict verdict) => switch (verdict) {
        PhotoVerdict.likelyGenuine => Icons.verified_outlined,
        PhotoVerdict.possiblyEdited => Icons.auto_fix_high,
        PhotoVerdict.likelyAiGenerated => Icons.smart_toy_outlined,
        PhotoVerdict.inconclusive => Icons.help_outline,
      };

  static Color signalColor(EvidenceSignal signal) => switch (signal) {
        EvidenceSignal.supportsGenuine => const Color(0xFF16A34A),
        EvidenceSignal.supportsManipulation => const Color(0xFFDC2626),
        EvidenceSignal.neutral => AppColors.textSecondary,
      };

  static IconData signalIcon(EvidenceSignal signal) => switch (signal) {
        EvidenceSignal.supportsGenuine => Icons.check_circle_outline,
        EvidenceSignal.supportsManipulation => Icons.warning_amber_rounded,
        EvidenceSignal.neutral => Icons.remove_circle_outline,
      };
}
