const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatFullDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

String formatDateRelative(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(date.year, date.month, date.day);
  final difference = today.difference(that).inDays;
  if (difference == 0) return 'Today';
  if (difference == 1) return 'Yesterday';
  return formatFullDate(date);
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
