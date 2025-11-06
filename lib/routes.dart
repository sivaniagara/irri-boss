

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/presentation/pages/sign_up_page.dart';
import 'package:niagara_smart_drip_irrigation/features/controllerLive/presentation/pages/controller_live_page.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/pages/chat.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/pages/groups.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/pages/sub_users.dart';

import 'core/di/injection.dart' as di;
import 'core/utils/route_constants.dart';
import 'core/widgets/app_drawer.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dealer_dashboard/presentation/pages/dealer_dashboard_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AppRouter {
  late final GoRouter router;
  final AuthBloc authBloc;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: RouteConstants.login,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState is Authenticated;
        final isOtpSent = authState is OtpSent;

        print('GoRouter redirect: authState=$authState, currentLocation=${state.matchedLocation}');

        if (isOtpSent && state.matchedLocation != RouteConstants.verifyOtp) {
          print('Redirecting to OTP screen: ${RouteConstants.verifyOtp}');
          return RouteConstants.verifyOtp;
          return RouteConstants.dealerDashboard;
        }
        if (isLoggedIn &&
            (state.matchedLocation == RouteConstants.login ||
                state.matchedLocation == RouteConstants.verifyOtp)) {
          print('Redirecting to dashboard: ${RouteConstants.dashboard}');
          return RouteConstants.dealerDashboard;
          return RouteConstants.dealerDashboard;
        }
        if (!isLoggedIn &&
            !isOtpSent &&
            state.matchedLocation != RouteConstants.login &&
            state.matchedLocation != RouteConstants.verifyOtp) {
          print('Redirecting to login: ${RouteConstants.login}');
          return RouteConstants.login;
          return RouteConstants.dealerDashboard;
        }
        print('No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          name: 'login',
          path: RouteConstants.login,
          builder: (context, state) {
            print('Building LoginPage, AuthBloc state: ${authBloc.state}');
            return BlocProvider.value(
              value: authBloc,
              child: const LoginPage(),
            );
          },
        ),
        GoRoute(
          name: 'signUp',
          path: RouteConstants.signUp,
          builder: (context, state) {
            print('Building SignUpPage, AuthBloc state: ${authBloc.state}');
            return BlocProvider.value(
              value: authBloc,
              child: UserProfileForm(
                isEdit: false,
              ),
            );
          },
        ),
        GoRoute(
          name: 'editProfile',
          path: RouteConstants.editProfile,
          builder: (context, state) {
            print('Building EditProfile, AuthBloc state: ${authBloc.state}');
            final authState = authBloc.state;
            final initialData = authState is Authenticated ? authState.user.userDetails : null;
            return BlocProvider.value(
              value: authBloc,
              child: UserProfileForm(
                key: const ValueKey('editProfile'),
                isEdit: true,
                initialData: initialData,
              ),
            );
          },
        ),
        GoRoute(
          name: 'verifyOtp',
          path: RouteConstants.verifyOtp,
          builder: (context, state) {
            print('Building OtpVerificationPage, AuthBloc state: ${authBloc.state}');
            final authState = authBloc.state;
            final params = state.extra is Map ? state.extra as Map : null;
            final verificationId = params?['verificationId'] ?? (authState is OtpSent ? authState.verificationId : '');
            final phone = params?['phone'] ?? (authState is OtpSent ? authState.phone : '');
            final countryCode = params?['countryCode'] ?? (authState is OtpSent ? authState.countryCode : '');

            if (verificationId.isEmpty || phone.isEmpty) {
              print('Invalid OTP parameters, redirecting to login');
              return const LoginPage();
            }

            return BlocProvider.value(
              value: authBloc,
              child: OtpVerificationPage(
                verificationId: verificationId,
                phone: phone,
                countryCode: countryCode,
              ),
            );
          },
        ),
        GoRoute(
          name: 'dashboard',
          path: RouteConstants.dashboard,
          builder: (context, state) {
            print('Building DashboardPage, AuthBloc state: ${authBloc.state}');  // Add for debug
            return BlocProvider.value(
              value: authBloc,
              child: const DashboardPage(),
            );
          },
        ),
        GoRoute(
          name: 'ctrlLivePage',
          path: RouteConstants.ctrlLivePage,
          builder: (context, state) {
            print('Building ctrlLivePage, AuthBloc state: ${authBloc.state}');  // Add for debug
            return BlocProvider.value(
              value: authBloc,
              child: const CtrlLivePage(),
            );
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.matchedLocation;
            String title = 'Dealer Dashboard';
            if (location == RouteConstants.groups) {
              title = 'Groups';
            } else if (location == RouteConstants.subUsers) {
              title = 'Sub Users';
            } else if (location == RouteConstants.chat) {
              title = 'Chat';
            }
            return BlocProvider<DashboardBloc>(
              create: (_) => di.sl<DashboardBloc>(),
              child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(title),
                  flexibleSpace: _buildAppBarBackground(),
                ),
                drawer: const AppDrawer(),
                body: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(child: _buildBackgroundDecorations()),
                    child
                  ],
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              name: 'dealerDashboard',
              path: RouteConstants.dealerDashboard,
              builder: (context, state) {
                return BlocProvider.value(
                  value: authBloc,
                  child: const DealerDashboardPage(),
                );
              },
            ),
            GoRoute(
              name: 'groups',
              path: RouteConstants.groups,
              builder: (context, state) {
                return BlocProvider.value(
                  value: authBloc,
                  child: const Groups(),
                );
              },
            ),
            GoRoute(
              name: 'subUsers',
              path: RouteConstants.subUsers,
              builder: (context, state) {
                return BlocProvider.value(
                  value: authBloc,
                  child: const SubUsers(),
                );
              },
            ),
            GoRoute(
              name: 'chat',
              path: RouteConstants.chat,
              builder: (context, state) {
                return BlocProvider.value(
                  value: authBloc,
                  child: const Chat(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarBackground() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.02)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.06), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.04), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}