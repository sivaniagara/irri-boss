import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ExcelHelper {
  static Future<String> createExcel({
    required String title,
    required List<Map<String, dynamic>> data,
  }) async {
    if (data.isEmpty) {
      throw Exception("No data provided");
    }

    final headers = data.first.keys.toList();

    final excel = Excel.createExcel();
    final sheet = excel[title];

    /// 🔹 Merge title row
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(
        columnIndex: headers.length - 1,
        rowIndex: 0,
      ),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue(title);

    /// 🔹 Header row
    sheet.appendRow(
      headers.map((h) => TextCellValue(h)).toList(),
    );

    /// 🔹 Data rows
    for (final row in data) {
      sheet.appendRow(
        headers.map((h) => _toCellValue(row[h])).toList(),
      );
    }

    final dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("Storage not accessible");

    final formatted =
    DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final fileName =
        "${title.replaceAll(' ', '_')}_$formatted.xlsx";

    final filePath = "${dir.path}/$fileName";

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// 🔹 Centralized CellValue converter
  static CellValue _toCellValue(dynamic value) {
    if (value == null) {
      return  TextCellValue('');
    }
    if (value is int) {
      return IntCellValue(value);
    }
    if (value is double) {
      return DoubleCellValue(value);
    }
    if (value is bool) {
      return BoolCellValue(value);
    }
    return TextCellValue(value.toString());
  }
}
