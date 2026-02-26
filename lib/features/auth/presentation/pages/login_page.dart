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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, authState) =>
                  LoginPageListener.handleAuthState(context, authState),
              builder: (context, authState) {
                final cubit = context.watch<LoginPageCubit>();
                final state = cubit.state;

                if (authState is AuthLoading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 4),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 🔹 Title
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign in using your registered mobile number. This helps us securely access your account.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      // 🔹 Illustration
                      Center(
                        child: !state.useOtpLogin ? Image.asset("assets/images/common/login.png",
                          height: 200,) : Image.asset("assets/images/common/otp_login.png",
                          height: !state.useOtpLogin ? 200 : 250,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Mobile Number",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // 🔹 FORM CARD
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Form(
                          key: state.formKey,
                          child: Column(
                            children: [
                              IntlPhoneField(
                                controller: state.phoneController,
                                initialCountryCode: 'IN',
                                decoration: InputDecoration(
                                  hintText: "Mobile Number", // 👈 use hint instead of label
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                onCountryChanged: (country) {
                                  cubit.updateCountryCode(
                                      '+${country.dialCode}');
                                },
                                validator: (value) =>
                                value?.number.isEmpty ?? true
                                    ? 'Please enter a valid phone number'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 🔹 Password

                      if (!state.useOtpLogin) ...[
                        const Text(
                          "Password",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: state.passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            suffixIcon: const Icon(Icons.visibility_off, size: 20),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your password'
                              : null,
                        ),
                      ],


                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ],


                      const SizedBox(height: 10),

                      // 🔹 SIGN UP
                      Center(
                        child: TextButton(
                          onPressed: () => context.push(AuthRoutes.signUp),
                          child: const Text(
                            "Not registered? Create an account",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      // 🔹 Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1689D7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            !state.useOtpLogin ? "Log In" : "Get OTP",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 OR Divider
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Or"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: cubit.toggleLoginMode,
                          icon: const Icon(Icons.lock_outline),
                          label:  Text(!state.useOtpLogin ? "Continue with OTP Verification" : "Continue with UserID ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ) ,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        ),

      ),
    );
  }



}