import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../presentation/bloc/service_request_bloc.dart';
import '../presentation/bloc/service_request_event.dart';
import '../presentation/pages/service_request_page.dart';

class ServiceRequestRoutes {
  static const String serviceRequest = "/serviceRequest";
}

final serviceRequestRoutes = [
  GoRoute(
    path: ServiceRequestRoutes.serviceRequest,
    builder: (context, state) {
      final params = state.uri.queryParameters;
      final userId = params['userId'] ?? '';
      return BlocProvider<ServiceRequestBloc>(
        create: (context) => sl<ServiceRequestBloc>()..add(FetchServiceRequests(userId: userId)),
        child: const ServiceRequestPage(),
      );
    },
  ),
];
