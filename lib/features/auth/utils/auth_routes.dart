import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_state.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/otp_page.dart';
import '../presentation/pages/sign_up_page.dart';

class AuthRoutes {
  static const String login = "/login";
  static const String verifyOtp = "/verifyOtp";
  static const String signUp = "/signUp";
  static const String editProfile = "/editProfile";
  static const String controllerDetails = "/controllerDetails";
}

final authRoutes = <GoRoute>[
  _authRoute(
    name: 'login',
    path: AuthRoutes.login,
    builder: (context, state) => const LoginPage(),
  ),
  _authRoute(
    name: 'signUp',
    path: AuthRoutes.signUp,
    builder: (context, state) => UserProfileForm(isEdit: false),
  ),
  _authRoute(
    name: 'editProfile',
    path: AuthRoutes.editProfile,
    builder: (context, state) {
      final authState = sl.get<AuthBloc>().state;
      final initialData = authState is Authenticated ? authState.user.userDetails : null;
      return UserProfileForm(
        key: const ValueKey('editProfile'),
        isEdit: true,
        initialData: initialData,
      );
    },
  ),
  _authRoute(
    name: 'verifyOtp',
    path: AuthRoutes.verifyOtp,
    builder: (context, state) {
      final authState = sl.get<AuthBloc>().state;
      final params = state.extra is Map ? state.extra as Map : null;
      final verificationId = params?['verificationId'] ?? (authState is OtpSent ? authState.verificationId : '');
      final phone = params?['phone'] ?? (authState is OtpSent ? authState.phone : '');
      final countryCode = params?['countryCode'] ?? (authState is OtpSent ? authState.countryCode : '');

      if (verificationId.isEmpty || phone.isEmpty) {
        return const LoginPage();
      }

      return OtpVerificationPage(
        verificationId: verificationId,
        phone: phone,
        countryCode: countryCode,
      );
    },
  ),
];

Widget _buildWithAuthBloc(Widget child) => BlocProvider.value(value: sl.get<AuthBloc>(), child: child);

GoRoute _authRoute({
  required String name,
  required String path,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    name: name,
    path: path,
    builder: (context, state) => _buildWithAuthBloc(builder(context, state)),
  );
}