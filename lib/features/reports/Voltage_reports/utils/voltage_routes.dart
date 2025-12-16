//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_event.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/pages/voltagegraphPage.dart';
//
// import '../../../../core/di/injection.dart' as di;
//
//
//
// /// Page Route Name Constants
// abstract class VoltGraphPageRoutes {
//   static const String VoltGraphPageRoute = '/sendRevMsgPage';
// }
//
// /// API URL Pattern
// class VoltGraphPageUrls {
//   static const String getVoltGraphUrl =
//       'user/:userId/subuser/:subuserId/controller/:controllerId/report'
//       '?fromDate=":fromDate"&toDate=":toDate"&type=sendrevmsg';
// }
//
// final VoltGraphPageRoute = <GoRoute>[
//   GoRoute(
//     path: VoltGraphPageRoutes.VoltGraphPageRoute,
//     name: 'VoltGraphPage',
//     builder: (context, state) {
//       /// Get parameters from extra
//       final params = state.extra as Map<String, dynamic>;
//
//       final userId = params["userId"];
//       final subuserId = params["subuserId"] ?? 0;
//       final controllerId = params["controllerId"];
//       final fromDate = params["fromDate"] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final toDate = params["toDate"] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//         return BlocProvider(
//         create: (_) => di.sl<VoltageGraphBloc>()
//           ..add(LoadVoltageGraphEvent(
//             userId: userId,
//             subuserId: subuserId,
//             controllerId: controllerId,
//             fromDate: fromDate,
//             toDate: toDate,
//           )),
//         child: VoltageGraphPage(params: params,),
//       );
//     },
//   ),
// ];
