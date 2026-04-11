
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<ReportDateResult?> pickReportDate({
  required BuildContext context,
  bool allowRange = false,
  String? initialFromDate,
  String? initialToDate,
}) async {
  final formatter = DateFormat('yyyy-MM-dd');

  if (!allowRange) {
    final initialDate = initialFromDate != null
        ? DateTime.parse(initialFromDate)
        : DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date == null) return null;

    final formatted = formatter.format(date);
    return ReportDateResult(fromDate: formatted, toDate: formatted);
  }

  final initialRange = DateTimeRange(
    start: initialFromDate != null
        ? DateTime.parse(initialFromDate)
        : DateTime.now().subtract(const Duration(days: 1)),
    end: initialToDate != null
        ? DateTime.parse(initialToDate)
        : DateTime.now(),
  );

  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: initialRange,
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

