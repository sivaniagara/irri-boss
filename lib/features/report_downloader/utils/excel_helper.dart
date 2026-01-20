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

    /// 🔹 Title row (row 0)
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
    // final headers = data.first.keys.toList();
    // final excel = Excel.createExcel();
    //
    // /// ✅ Get existing default sheet
    // final String defaultSheet = excel.getDefaultSheet()!;
    // final sheet = excel[defaultSheet];
    //
    // /// ✅ Rename it (safe)
    // excel.rename(defaultSheet, title);
    //
    // /// 🔹 Now write data ONLY to this sheet
    // sheet.merge(
    //   CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    //   CellIndex.indexByColumnRow(
    //     columnIndex: headers.length - 1,
    //     rowIndex: 0,
    //   ),
    // );
    //
    // sheet
    //     .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
    //     .value = TextCellValue(title);

    /// 🔹 Header row (row 1)
    for (int col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 1))
          .value = TextCellValue(headers[col]);
    }

    /// 🔹 Data rows (row 2+)
    int rowIndex = 2;
    for (final row in data) {
      for (int col = 0; col < headers.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: rowIndex,
        ))
            .value = _toCellValue(row[headers[col]]);
      }
      rowIndex++;
    }

    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

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
