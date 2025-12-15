import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';

import '../../../../core/utils/route_constants.dart';
import '../../domain/usecases/login_params.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../cubit/login_ui_cubit.dart';

class LoginPageListener {
  static void handleAuthState(BuildContext context, AuthState state) {
    final cubit = context.read<LoginPageCubit>();

    if (state is PhoneNumberChecked) {
      if (state.exists) {
        final useOtp = cubit.state.useOtpLogin;
        if (useOtp) {
          context.read<AuthBloc>().add(SendOtpEvent(phone: state.phone, countryCode: state.countryCode));
        } else {
          context.read<AuthBloc>().add(LoginWithPasswordEvent(phone: state.phone, password: cubit.state.passwordController.text));
        }
      } else {
        cubit.setError('Phone number not registered. Please sign up.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not registered. Please sign up.')),
        );
      }
    }

    if (state is OtpSent) {
      cubit.clearError();
    }

    if (state is Authenticated) {
      if (state.user.userDetails.userType == 2) {
        context.go(DealerRoutes.dealerDashboard);
      } else if (state.user.userDetails.userType == 1) {
        context.go(DashBoardRoutes.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin cannot login through mobile"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }

    if (state is AuthError) {
      String displayMessage = state.message;
      if (state.message.contains('Invalid phone number format')) {
        displayMessage = 'Invalid phone number format. Please enter a valid number.';
      } else if (state.message.contains('Login failed')) {
        displayMessage = 'Invalid password. Please try again.';
      }

      cubit.setError(displayMessage);

      if (state.code == 'too-many-requests') {
        cubit.setRateLimited(true);
        Future.delayed(const Duration(minutes: 2), () {
          if (context.mounted) cubit.setRateLimited(false);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(displayMessage)));
    }
  }
}