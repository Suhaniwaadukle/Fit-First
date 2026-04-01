import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommonFormatter {
  String checkValue(String? value) {
    if (value == null || value.isEmpty || value == 'null' || value == 'Null') {
      return '';
    } else {
      return value;
    }
  }

  TimeOfDay parseTimeScheduler(String timeString) {
    try {
      // Step 1: Print raw character codes to find hidden characters
      debugPrint("Original input: '$timeString'");
      debugPrint("Code units: ${timeString.codeUnits}");
      // Step 2: Remove ALL non-ASCII characters and normalize spaces
      String cleaned = timeString
          .replaceAll(RegExp(r'[^\x20-\x7E]'), '') // keep only visible ASCII
          .replaceAll(RegExp(r'\s+'), ' ') // normalize spaces
          .trim();
      debugPrint("Cleaned input: '$cleaned'");
      debugPrint("Cleaned code units: ${cleaned.codeUnits}");
      DateTime printTime = parseTimeToDateTime(cleaned);
      debugPrint("date code units: $printTime");
      return TimeOfDay.fromDateTime(printTime);
    } catch (e) {
      return TimeOfDay.now(); // fallback
    }
  }

  DateTime parseTimeToDateTime(String timeString) {
    final format = DateFormat('h:mm a'); // e.g. "8:00 AM"
    final parsedTime = format.parse(timeString); // DateTime with default date 1970-01-01

    final now = DateTime.now();
    // Replace year, month, day with today's date but keep parsed hour and minute
    return DateTime(
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
      parsedTime.second,
      parsedTime.millisecond,
      parsedTime.microsecond,
    );
  }

  String formatTimeWPGlobal(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime); // Returns formatted time like "9:30 AM"
  }

  String convertTo12HourFormat(String timeString) {
    try {
      final time = TimeOfDay(
        hour: int.parse(timeString.split(":")[0]),
        minute: int.parse(timeString.split(":")[1]),
      );

      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';

      return '$hour:$minute $period';
    } catch (e) {
      return timeString; // fallback in case of error
    }
  }
}
