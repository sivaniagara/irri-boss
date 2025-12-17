import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'features/controller_settings/program_list/presentation/cubit/controller_context_cubit.dart';
import 'firebase_options.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on UnsupportedError catch (e) {
      // Platform not supported for Firebase initialization (e.g., desktop without config)
      // Log and continue; Firebase-dependent features should handle missing Firebase gracefully.
      if (kDebugMode) print('Firebase initialize skipped: $e');
    }
  }
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await di.sl<NotificationService>().init();
  final authBloc = di.sl<AuthBloc>();
  authBloc.add(CheckCachedUserEvent());

  appRouter = AppRouter(authBloc: authBloc);

  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<ControllerContextCubit>()),
        ],
        child: RootApp(authBloc: authBloc),
      ),

  );
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
