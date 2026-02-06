
import '../../../core/di/injection.dart';
import '../data/repositories/report_repository_impl.dart';
import '../domain/repositories/report_repository.dart';
import '../domain/usecase/download_report_excel.dart';
import '../presentation/bloc/report_bloc.dart';

Future<void> initReportDownloadDependencies() async {
  sl.registerLazySingleton<ReportRepository>(
        () => ReportRepositoryImpl(),
  );

  sl.registerLazySingleton(
        () => DownloadReportExcel(sl()),
  );

  sl.registerFactory(
        () => ReportDownloadBloc(sl()),
  );
}
