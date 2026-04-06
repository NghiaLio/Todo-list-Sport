class TimeConvert {
  static String convertDateTimeToString(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  static String convertStringTimeToStringTime(String dateTimeString) {
    final raw = dateTimeString.trim().toLowerCase();
    if (raw.isEmpty) {
      return '00h 00m';
    }

    // Format: HH:mm
    final hhmm = RegExp(r'^(\d{1,2}):(\d{1,2})$').firstMatch(raw);
    if (hhmm != null) {
      final hour = int.tryParse(hhmm.group(1) ?? '0') ?? 0;
      final minute = int.tryParse(hhmm.group(2) ?? '0') ?? 0;
      return _formatHourMinute(hour, minute);
    }

    // Fallback: pure minute number, e.g. "90"
    final onlyNumber = int.tryParse(raw);
    if (onlyNumber != null) {
      final hour = onlyNumber ~/ 60;
      final minute = onlyNumber % 60;
      return _formatHourMinute(hour, minute);
    }

    // Keep original text when unknown format.
    return dateTimeString;
  }

  static String _formatHourMinute(int hour, int minute) {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '${hourStr}h ${minuteStr}m';
  }
}
