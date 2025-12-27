import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/reportMenu/utils/reportmenu_params.dart';

import '../bloc/report_menu_bloc.dart';
import '../presentation/reportmenu_page.dart';


class ReportPageRoutes {
  static const String reportMenu = '/reportMenu';

  static GoRoute route = GoRoute(
    path: reportMenu,
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;

      return BlocProvider(
        create: (_) => ReportMenuBloc(),
        child: ReportMenuPage(params: params),
      );
    },
  );
}
