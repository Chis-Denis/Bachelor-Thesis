enum IssueStatus {
  open,
  reviewed;

  String get label => switch (this) {
        IssueStatus.open => 'Open',
        IssueStatus.reviewed => 'Reviewed',
      };
}
