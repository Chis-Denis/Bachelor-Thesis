import '../../domain/issues/evidence_item.dart';

class EvidenceItemDto {
  final String label;
  final String detail;
  final EvidenceSignal signal;

  const EvidenceItemDto({
    required this.label,
    required this.detail,
    required this.signal,
  });

  factory EvidenceItemDto.fromDomain(EvidenceItem item) => EvidenceItemDto(
        label: item.label,
        detail: item.detail,
        signal: item.signal,
      );
}
