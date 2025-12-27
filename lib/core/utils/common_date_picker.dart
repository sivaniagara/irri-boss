
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<ReportDateResult?> pickReportDate({
  required BuildContext context,
  bool allowRange = false,
}) async {
  final formatter = DateFormat('yyyy-MM-dd');

  if (!allowRange) {
    // 🔹 Single date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) return null;

    final formatted = formatter.format(date);
    return ReportDateResult(fromDate: formatted, toDate: formatted);
  }

  // 🔹 Range date
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 1)),
      end: DateTime.now(),
    ),
  );

  if (range == null) return null;

  return ReportDateResult(
    fromDate: formatter.format(range.start),
    toDate: formatter.format(range.end),
  );
}
class ReportDateResult {
  final String fromDate;
  final String toDate;

  const ReportDateResult({
    required this.fromDate,
    required this.toDate,
  });
}

