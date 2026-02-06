import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../presentation/bloc/serial_set_bloc.dart';
import '../presentation/bloc/serial_set_event.dart';
import '../presentation/pages/serial_set_menu_page.dart';

class SerialSetRoutes {
  static const String serialSetMenu = "/serialSetMenu";

  static List<GoRoute> get routes => [
        GoRoute(
          path: serialSetMenu,
          name: 'serialSetMenu',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            final userId = extras['userId'] as String;
            final controllerId = extras['controllerId'] as String;
            final deviceId = extras['deviceId'] as String;
            final subUserId = extras['subUserId'] as String;

            return BlocProvider(
              create: (context) => sl<SerialSetBloc>()
                ..add(FetchSerialSetEvent(
                  userId: userId,
                  controllerId: controllerId,
                  deviceId: deviceId,
                  subUserId: subUserId,
                )),
              child: const SerialSetMenuPage(),
            );
          },
        ),
      ];
}
