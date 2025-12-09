import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/mqtt/bloc/mqtt_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/di/injection.dart' as di;
import 'core/services/notification_service.dart';
import 'core/theme/theme_provider.dart';
import 'routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notificationService = di.sl<NotificationService>();
  notificationService.handleBackgroundMessage(message);
}

late final AppRouter appRouter;

Future<void> appMain() async {
  await di.init();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await di.sl<NotificationService>().init();
  final authBloc = di.sl<AuthBloc>();
  authBloc.add(CheckCachedUserEvent());

  appRouter = AppRouter(authBloc: authBloc);

  runApp(RootApp(authBloc: authBloc));
}

class RootApp extends StatelessWidget {
  final AuthBloc authBloc;
  final ThemeProvider _themeProvider = di.sl<ThemeProvider>();

  RootApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext dialogContext) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<MqttBloc>(
          lazy: false,
          create: (context) {
            final bloc = di.sl<MqttBloc>();
            return bloc;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            themeMode: ThemeMode.light,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}