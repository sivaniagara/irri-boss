import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import '../../../../core/di/injection.dart' as di;
import '../bloc/report_menu_bloc.dart';
import '../presentation/reportmenu_page.dart';


class ReportPageRoutes {
  static const String reportMenu = '/reportMenu';
}

final reportPageRoutes = <GoRoute>[
  GoRoute(
    path: ReportPageRoutes.reportMenu,
    name: 'reportMenu',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>? ?? {};

      return BlocProvider(
        create: (_) => ReportMenuBloc(),
        child: ReportMenuPage(params: params),
      );
    },
  ),
];





