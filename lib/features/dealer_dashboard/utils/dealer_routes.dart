import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/dealer_customer_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/shared_devices_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/pages/shared_device_page.dart';

import '../../../core/di/injection.dart';
import '../presentation/pages/dealer_customer_list_page.dart';

class DealerRoutes {
  static const String dealerDashboard = "/dealerDashboard";
  static const String serviceRequest = "/serviceRequest";
  static const String sellingDevice = "/sellingDevice";
  static const String customerDevice = "/customerDevice";
  static const String sharedDevice = "/sharedDevice";
  static const String selectedCustomer = "/selectedCustomer";

  static List<GoRoute> dealerRoutes = <GoRoute>[
    GoRoute(
      path: DealerRoutes.sharedDevice,
      builder: (context, state) {
        final params = state.uri.queryParameters as Map<String, dynamic>;
        return BlocProvider<SharedDevicesCubit>(
            create: (_) => sl<SharedDevicesCubit>()..getSharedDevices(params['userId']),
            child: SharedDevicesPage()
        );
      },
    ),
    GoRoute(
      path: customerDevice,
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId']!;
        return BlocProvider(
          create: (context) => sl<DealerCustomerCubit>()..fetchDealerCustomers(userId),
          child: DealerCustomerListPage(),
        );
      },
    ),
    GoRoute(
      path: selectedCustomer,
      name: 'selectedCustomer',
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId']!;
        return BlocProvider(
          create: (context) => sl<DealerCustomerCubit>()..fetchSelectedCustomers(userId),
          child: DealerCustomerListPage(),
        );
      },
    ),
  ];
}