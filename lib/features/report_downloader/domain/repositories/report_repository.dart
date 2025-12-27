abstract class ReportRepository {
  Future<String> downloadExcel({
    required String reportTitle,
    required String url,
  });
}
