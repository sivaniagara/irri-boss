import '../repositories/report_repository.dart';

class DownloadReportExcel {
  final ReportRepository repository;

  DownloadReportExcel(this.repository);

  Future<String> call({
    required String reportTitle,
    required String url,
  }) {
    return repository.downloadExcel(
      reportTitle: reportTitle,
      url: url,
    );
  }
}
