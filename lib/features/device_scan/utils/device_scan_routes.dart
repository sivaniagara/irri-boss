import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/di/injection.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/route_constants.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../pages/device_list_page.dart';
import '../pages/qr_scanner_page.dart';

final deviceScanRoutes = [
  GoRoute(
    path: RouteConstants.QRScannerPage,
    builder: (context, state) => BlocProvider(
      create: (context) => sl<QRDeviceBloc>()..add(LoadDevices()),
      child: const QrScannerPage(),
    ),
  ),
  GoRoute(
    path: RouteConstants.QRScannerListPage,
    builder: (context, state) => BlocProvider(
      create: (context) => sl<QRDeviceBloc>()..add(LoadDevices()),
      child: const QRDeviceListPage(),
    ),
  ),
];
