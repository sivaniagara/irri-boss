import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';

import '../../../core/di/injection.dart';
import '../presentation/pages/dealer_dashboard_page.dart';
import '../presentation/pages/shared_device.dart';

class DealerRoutes {
  static const String dealerDashboard = "/dealerDashboard";
  static const String serviceRequest = "/serviceRequest";
  static const String sellingDevice = "/sellingDevice";
  static const String customerDevice = "/customerDevice";
  static const String sharedDevice = "/sharedDevice";
  static const String selectedCustomer = "/selectedCustomer";
}

final dealerRoutes = <GoRoute>[
  GoRoute(
    path: DealerRoutes.dealerDashboard,
    builder: (context, state) {
      final params = state.uri.queryParameters as Map<String, dynamic>;
      return DealerDashboardPage(userData: params);
    },
  ),
  GoRoute(
    path: DealerRoutes.sharedDevice,
    builder: (context, state) => const SharedDevicePage(),
  ),
];