import '../repositories/report_repository.dart';



  class DownloadReportExcel {
  final ReportRepository repository;

  DownloadReportExcel(this.repository);

  Future<String> call({
  required String reportTitle,
  required List<Map<String, dynamic>> data,
  }) {
  return repository.downloadExcel(
  reportTitle: reportTitle,
  data: data,
  );
  }
  }

