import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/utils/app_images.dart';
import '../../auth.dart';
import '../../utils/auth_routes.dart';
import 'login_page_listener.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);

    return BlocProvider(
      create: (_) => LoginPageCubit(),
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(dialogContext).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.9),
                theme.primaryColorDark.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, authState) => LoginPageListener.handleAuthState(context, authState),
                builder: (context, authState) {
                  final cubit = context.watch<LoginPageCubit>();
                  final state = cubit.state;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: authState is AuthLoading
                        ? const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 6),
                    )
                        : SingleChildScrollView(
                      key: const ValueKey('form'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 50),
                          // Logo
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.asset(
                                  NiagaraCommonImages.logoLarge,
                                  height: 140,
                                  width: 140,
                                  fit: BoxFit.contain,
                                )
                                    .animate()
                                    .slideY(begin: 1, end: 0, duration: 1200.ms, curve: Curves.easeOut)
                                    .then()
                                    .shimmer(duration: 2000.ms),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 12.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 800.ms),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in to your account',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 1000.ms),
                          const SizedBox(height: 48),

                          // Form Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: state.formKey,
                                child: Column(
                                  children: [
                                    IntlPhoneField(
                                      controller: state.phoneController,
                                      initialCountryCode: 'IN',
                                      style: const TextStyle(color: Colors.black),
                                      dropdownTextStyle: const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.9),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                        labelStyle: const TextStyle(color: Colors.black45),
                                        prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                                      ),
                                      onCountryChanged: (country) {
                                        cubit.updateCountryCode('+${country.dialCode}');
                                      },
                                      validator: (value) => value?.number.isEmpty ?? true ? 'Please enter a valid phone number' : null,
                                    ),
                                    if (!state.useOtpLogin) ...[
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: state.passwordController,
                                        style: const TextStyle(color: Colors.black),
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.9),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                          labelStyle: const TextStyle(color: Colors.black45),
                                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                                        ),
                                        validator: (value) => value?.isEmpty ?? true ? 'Please enter your password' : null,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms),

                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: cubit.toggleLoginMode,
                            child: Text(
                              state.useOtpLogin ? 'Use Password Instead' : 'Use OTP Instead',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ).animate().fadeIn(duration: 1200.ms),

                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 500.ms),
                          ],

                          const SizedBox(height: 32),
                          CustomButton(
                            onPressed: state.isRateLimited
                                ? null
                                : () {
                              if (state.formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  CheckPhoneNumberEvent(
                                    phone: state.phoneController.text,
                                    countryCode: state.countryCode,
                                  ),
                                );
                              }
                            },
                            text: state.useOtpLogin ? 'Send OTP' : 'Login',
                            isLoading: authState is AuthLoading,
                          ),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => context.push(AuthRoutes.signUp),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Not registered? ',
                                style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                    text: 'Create an account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 1200.ms),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}