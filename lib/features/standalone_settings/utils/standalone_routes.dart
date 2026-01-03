import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../presentation/bloc/standalone_bloc.dart';
import '../presentation/bloc/standalone_event.dart';
import '../presentation/pages/standalone_page.dart';


abstract class StandaloneRoutes {
  static const String standalone = '/dashboard/standalone'; 
}


final standaloneRoutes = <GoRoute>[
  GoRoute(
    path: 'standalone', 
    name: 'standalone',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;
      final userId = params["userId"]?.toString() ?? '';
      final controllerId = params["controllerId"]?.toString() ?? '';

      return BlocProvider(
        create: (_) => di.sl<StandaloneBloc>()
          ..add(FetchStandaloneDataEvent(userId: userId, controllerId: controllerId)),
        child: StandalonePage(data: params,),
      );
    },
  ),
];
