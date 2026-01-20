import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../presentation/cubit/dealer_list_cubit.dart';
import '../presentation/pages/dealer_list_page.dart';

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
        return BlocProvider<DealerListCubit>(
            create: (_) => sl<DealerListCubit>()..fetchSharedDevices(params['userId']),
            child: DealerListPage()
        );
      },
    ),
    GoRoute(
      path: customerDevice,
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId']!;
        return BlocProvider(
          create: (context) => sl<DealerListCubit>()..fetchDealerCustomers(userId),
          child: DealerListPage(),
        );
      },
    ),
    GoRoute(
      path: selectedCustomer,
      name: 'selectedCustomer',
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId']!;
        return BlocProvider(
          create: (context) => sl<DealerListCubit>()..fetchSelectedCustomers(userId),
          child: DealerListPage(),
        );
      },
    ),
  ];
}