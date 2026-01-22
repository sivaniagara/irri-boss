 import '../../domain/repositories/report_repository.dart';
import '../../utils/excel_helper.dart';

 class ReportRepositoryImpl implements ReportRepository {
   @override
   Future<String> downloadExcel({
     required String reportTitle,
     required List<Map<String, dynamic>> data,
   }) async {
     if (data.isEmpty) {
       throw Exception("No data");
     }

     return ExcelHelper.createExcel(
       title: reportTitle,
       data: data,
     );
   }
 }

