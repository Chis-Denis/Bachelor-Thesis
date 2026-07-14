enum EvidenceSignal {
  supportsGenuine,
  supportsManipulation,
  neutral,
}

class EvidenceItem {
  final String label;
  final String detail;
  final EvidenceSignal signal;

  const EvidenceItem({
    required this.label,
    required this.detail,
    required this.signal,
  });
}
