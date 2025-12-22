 import '../../domain/repositories/report_repository.dart';
import '../../utils/excel_helper.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remote;

  ReportRepositoryImpl(this.remote);

  @override
  Future<String> downloadExcel({
    required String reportTitle,
    required String url,
  }) async {
    final data = await remote.fetchReport(url);
    if (data.isEmpty) {
      throw Exception("No data");
    }
    return ExcelHelper.createExcel(
      title: reportTitle,
      data: data,
    );
  }
}
