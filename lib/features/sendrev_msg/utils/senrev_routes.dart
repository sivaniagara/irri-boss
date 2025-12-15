
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../core/di/injection.dart' as di;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';  // your getIt instance
import '../presentation/bloc/sendrev_bloc.dart';
import '../presentation/bloc/sendrev_bloc_event.dart';
import '../presentation/pages/sendrevPage.dart';

/// Page Route Name Constants
abstract class SendRevPageRoutes {
  static const String sendRevMsgPage = '/sendRevMsgPage';
}

/// API URL Pattern
class SendRevPageUrls {
  static const String getSendRevMsgUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report'
      '?fromDate=":fromDate"&toDate=":toDate"&type=sendrevmsg';
}

final sendRevPageRoutes = <GoRoute>[
  GoRoute(
    path: SendRevPageRoutes.sendRevMsgPage,
    name: 'SendRevMsgPage',
    builder: (context, state) {
      /// Get parameters from extra
      final params = state.extra as Map<String, dynamic>;

      final userId = params["userId"];
      final subuserId = params["subuserId"] ?? 0;
      final controllerId = params["controllerId"];
      final fromDate = params["fromDate"] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final toDate = params["toDate"] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

        return BlocProvider(
        create: (_) => di.sl<SendrevBloc>()
          ..add(LoadMessagesEvent(
            userId: userId,
            subuserId: subuserId,
            controllerId: controllerId,
            fromDate: fromDate,
            toDate: toDate,
          )),
        child: SendRevPage(params: params,),
      );
    },
  ),
];
