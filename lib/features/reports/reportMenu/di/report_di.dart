

import '../../../../core/di/injection.dart';
import '../bloc/report_menu_bloc.dart';

Future<void> initReportDependencies() async {
  /// Bloc
  sl.registerFactory<ReportMenuBloc>(
        () => ReportMenuBloc(),
  );
}
