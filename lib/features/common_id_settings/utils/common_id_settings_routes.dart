import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/pages/common_id_setting_page.dart';

import '../../../core/di/injection.dart' as di;
import '../../controller_settings/utils/controller_settings_routes.dart';
import '../../common_id_settings/presentation/bloc/common_id_settings_bloc.dart';
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommonIdSettingsRoutes {
  static const String commonIdSettings = "/commonIdSettings";
}

final commonIdSettingsGoRoutes = [
  GoRoute(
      path: CommonIdSettingsRoutes.commonIdSettings,
      builder: (context, state){
        final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context)=> di.sl<CommonIdSettingsBloc>()..add(FetchCommonIdSettings(userId: controllerContext.userId, controllerId: controllerContext.controllerId)),
              ),
            ],
            child: CommonIdSettingPage()
        );
      }
  ),
];