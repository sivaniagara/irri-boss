import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/presentation/bloc/faultmsg_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/presentation/pages/faultmsgPage.dart';
import '../../../core/di/injection.dart';
import '../presentation/bloc/faultmsg_bloc_event.dart';


/// Page Route Name Constants
abstract class FaultMsgPageRoutes {
  static const String FaultMsgMsgPage = '/FaultMsgMsgPage';
}

/// API URL Pattern
class FaultMsgPageUrls {
  static const String getFaultMsgMsgUrl =
      'user/:userId/subuser/:subUserId/controller/:controllerId/messages/';
}

final FaultMsgPagesRoutes = <GoRoute>[
  GoRoute(
    path: FaultMsgPageRoutes.FaultMsgMsgPage,
    name: 'FaultMsgPage',
    builder: (context, state) {
      /// Get parameters from extra
      final params = state.extra as Map<String, dynamic>? ?? {};

      // Parse values to int safely
      final int userId = int.tryParse(params["userId"]?.toString() ?? '0') ?? 0;
      final int subuserId = int.tryParse((params["subUserId"] ?? params["subuserId"])?.toString() ?? '0') ?? 0;
      final int controllerId = int.tryParse(params["controllerId"]?.toString() ?? '0') ?? 0;

      return BlocProvider<faultmsgBloc>(
        create: (_) => sl<faultmsgBloc>()
          ..add(LoadFaultMsgEvent(
            userId: userId,
            subuserId: subuserId,
            controllerId: controllerId,
          )),
        child: const faultmsgPage(),
      );
    },
  ),
];
