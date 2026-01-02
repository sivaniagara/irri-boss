import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/route_constants.dart';
import '../../controller_details/domain/usecase/controller_details_params.dart';
import '../../controller_details/presentation/bloc/controller_details_bloc.dart';
import '../../controller_details/presentation/bloc/controller_details_bloc_event.dart';
import '../../controller_details/presentation/pages/controller_details_page.dart';
import '../../controller_settings/utils/controller_settings_routes.dart';
import '../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../program_settings/utils/program_settings_routes.dart';
import '../../setserialsettings/domain/usecase/setserial_details_params.dart';
import '../../setserialsettings/presentation/bloc/set_serial_bloc.dart';
import '../../setserialsettings/presentation/bloc/setserial_bloc_event.dart';
import '../../setserialsettings/presentation/pages/setserial_page.dart';
import '../domain/entities/livemessage_entity.dart';
import '../presentation/bloc/dashboard_bloc.dart';
import '../presentation/bloc/dashboard_event.dart';
import '../presentation/pages/controller_live_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/program_preview_page.dart';

class DashBoardRoutes {
  static const String dashboard = "/dashboard";
  static const String ctrlLivePage = "/ctrlLivePage";
  static const String programPreview = "/programPreview";
}