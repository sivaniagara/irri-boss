abstract class ReportRepository {
  Future<String> downloadExcel({
    required String reportTitle,
    required List<Map<String, dynamic>> data,
  });
}