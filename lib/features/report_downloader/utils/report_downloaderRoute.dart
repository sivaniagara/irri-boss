import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
 import 'package:niagara_smart_drip_irrigation/features/report_downloader/presentation/pages/download_page.dart';

import '../../../../../core/di/injection.dart' as di;
 import '../presentation/bloc/report_bloc.dart';
/// Page Route Name Constants
abstract class ReportDownloadPageRoutes {
  static const String ReportDownloadPage = '/ReportDownload';
}

/// GoRouter config
final ReportDownloadRoutes = <GoRoute>[
  GoRoute(
    path: ReportDownloadPageRoutes.ReportDownloadPage,
    name: 'ReportDownloadPage',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      final String title = params['title'] ?? "";
      final List<Map<String, dynamic>> data = params['data'] ?? "";

      return  MultiBlocProvider(
        providers: [
          BlocProvider<ReportDownloadBloc>(
            create: (_) => di.sl<ReportDownloadBloc>()),
         ],
        child: ReportDownloadPage(title: title, data: data),
      );
    },
  ),
];
