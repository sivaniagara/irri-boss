import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

      return SendRevPage(
        params: params,
      );
    },
  ),
];
