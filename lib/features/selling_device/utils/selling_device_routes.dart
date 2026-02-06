import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../presentation/cubit/selling_device_cubit.dart';
import '../presentation/pages/selling_device_page.dart';
import '../presentation/pages/trace_device_page.dart';

class SellingDeviceRoutes {
  static const String sellingDevice = "/sellingDevice";
  static const String traceDevice = "/traceDevice";

  static List<GoRoute> sellingDeviceRoutes = [
    GoRoute(
      path: sellingDevice,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<SellingDeviceCubit>()..fetchCategories(),
          child: const SellingDevicePage(),
        );
      },
    ),
    GoRoute(
      path: traceDevice,
      name: 'traceDevice',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<SellingDeviceCubit>(),
          child: const TraceDevicePage(),
        );
      },
    ),
  ];
}
