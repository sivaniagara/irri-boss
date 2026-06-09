
import '../../../../core/di/injection.dart';
import '../../../mapping_and_unmapping_nodes/domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import '../bloc/report_menu_bloc.dart';

Future<void> initReportDependencies() async {
  /// Bloc
  sl.registerLazySingleton<ReportMenuBloc>(
        () => ReportMenuBloc(fetchMappingUnmappingNodesUsecase: sl<FetchMappingUnmappingNodesUsecase>()),
  );
}
