import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../presentation/bloc/alarm_bloc.dart';
import '../presentation/bloc/alarm_event.dart';
import '../presentation/pages/alarm_settings_page.dart';

class AlarmRoutes {
  static const String alarmSettings = "/alarmSettings";

  static List<GoRoute> get routes => [
        GoRoute(
          path: alarmSettings,
          name: 'alarmSettings',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            final userId = extras['userId'] as String;
            final controllerId = extras['controllerId'] as String;
            final deviceId = extras['deviceId'] as String;
            final subUserId = extras['subUserId'] as String;

            return BlocProvider(
              create: (context) => sl<AlarmBloc>()
                ..add(FetchAlarmDataEvent(
                  userId: userId,
                  controllerId: controllerId,
                  deviceId: deviceId,
                  subUserId: subUserId,
                )),
              child: const AlarmSettingsPage(),
            );
          },
        ),
      ];
}
