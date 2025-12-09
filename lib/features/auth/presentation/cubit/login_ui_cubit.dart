import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_ui_state.dart';

class LoginPageCubit extends Cubit<LoginPageState> {
  LoginPageCubit() : super(LoginPageState.initial());

  void toggleLoginMode() {
    emit(state.copyWith(useOtpLogin: !state.useOtpLogin, errorMessage: null));
    state.passwordController.clear();
  }

  void updateCountryCode(String code) => emit(state.copyWith(countryCode: code, errorMessage: null));
  void setError(String message) => emit(state.copyWith(errorMessage: message));
  void clearError() => emit(state.copyWith(errorMessage: null, isRateLimited: false));
  void setRateLimited(bool value) => emit(state.copyWith(isRateLimited: value));

  @override
  Future<void> close() {
    state.phoneController.dispose();
    state.passwordController.dispose();
    return super.close();
  }
}