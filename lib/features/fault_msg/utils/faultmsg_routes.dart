
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/presentation/bloc/faultmsg_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/fault_msg/presentation/pages/faultmsgPage.dart';
import '../../../core/di/injection.dart' as di;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../presentation/bloc/faultmsg_bloc_event.dart';  // your getIt instance


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
      final params = state.extra as Map<String, dynamic>;

      final userId = params["userId"];
      final subuserId = params["subuserId"] ?? 0;
      final controllerId = params["controllerId"];
      // http://3.1.62.165:8080/api/v1/user/2411/subuser/0/controller/4985/messages/

      print("${userId.runtimeType}");
      return BlocProvider(
        create: (_) => di.sl<faultmsgBloc>()
          ..add(LoadFaultMsgEvent(
            userId: userId,
            subuserId: subuserId,
            controllerId: controllerId,
          )),
        child: faultmsgPage(),
      );
    },
  ),
];
