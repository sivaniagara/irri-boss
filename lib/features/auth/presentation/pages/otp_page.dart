
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/route_constants.dart';
import '../../../auth/auth.dart';
import '../../../dashboard/utils/dashboard_routes.dart';
import '../widgets/custom_button.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String countryCode;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.countryCode,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late final GlobalKey<FormState> _formKey;
  final otpController = TextEditingController();
  String? errorMessage;
  bool isRateLimited = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,

      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  setState(() {
                    errorMessage = null;
                    isRateLimited = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Welcome ${state.user.userDetails.mobile}"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  if(state.user.userDetails.userType == 2) {
                    context.go(DealerRoutes.dealerDashboard);
                  } else if (state.user.userDetails.userType == 1){
                    context.go(DashBoardRoutes.dashboard, extra: state.user.userDetails);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Admin cannot login through mobile"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
                if (state is AuthError) {
                  setState(() {
                    errorMessage = state.code == 'timeout'
                        ? 'OTP request timed out. Please request a new OTP.'
                        : state.message;
                    if (state.code == 'too-many-requests') {
                      isRateLimited = true;
                      Future.delayed(const Duration(minutes: 2), () {
                        if (mounted) setState(() => isRateLimited = false);
                      });
                    }
                  });
                }
              },
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: state is AuthLoading
                      ? const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 6,
                    ),
                  )
                      : SingleChildScrollView(
                    key: const ValueKey('form'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "OTP Verification",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          " We’ve sent a one-time password (OTP) to your registered mobile number.",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        // 🔹 Illustration
                        Center(
                            child: Image.asset("assets/images/common/verify_otp.png", height: 200,)
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "We will send you one time password thisMobile Number.${widget.countryCode} ${widget.phone} ",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(color: Colors.white.withOpacity(0.3)),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.1),
                        //         blurRadius: 20,
                        //         spreadRadius: 5,
                        //       ),
                        //     ],
                        //   ),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(20.0),
                        //     child: Form(
                        //       key: _formKey,
                        //       child: TextFormField(
                        //         controller: otpController,
                        //         keyboardType: TextInputType.number,
                        //         style: TextStyle(color: Colors.black),
                        //         decoration: InputDecoration(
                        //           labelText: 'OTP',
                        //           labelStyle: TextStyle(color: Colors.black),
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(12),
                        //             borderSide: BorderSide.none,
                        //           ),
                        //           filled: true,
                        //           fillColor: Colors.white.withOpacity(0.9),
                        //           contentPadding: const EdgeInsets.symmetric(
                        //             horizontal: 16,
                        //             vertical: 14,
                        //           ),
                        //           prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        //           errorStyle: const TextStyle(color: Colors.redAccent),
                        //         ),
                        //         validator: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             return 'Please enter the OTP';
                        //           }
                        //           if (value.length != 6) {
                        //             return 'OTP must be 6 digits';
                        //           }
                        //           return null;
                        //         },
                        //       ),
                        //     ),
                        //   ),
                        // ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms),
                        Pinput(
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: Colors.blueAccent, width: 2),
                            ),
                          ),
                          onCompleted: (pin) => print("Entered Pin: $pin"),
                        ),

                        const SizedBox(height: 32),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => setState(() => errorMessage = null),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 500.ms).shake(duration: 600.ms, hz: 4),
                          ),
                        ],
                        const SizedBox(height: 32),
                        CustomButton(
                          onPressed: isRateLimited
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                VerifyOtpEvent(
                                  otp: widget.verificationId, countryCode: widget.countryCode, verificationId: otpController.text,
                                ),
                              );
                            }
                          },
                          text: 'Verify OTP',
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Didn't receive the code? "),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Resend",
                                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: isRateLimited
                              ? null
                              : () {
                            context.read<AuthBloc>().add(
                              SendOtpEvent(phone: widget.phone, countryCode: widget.countryCode),
                            );
                          },
                          child: Text(
                            isRateLimited ? 'Please wait before resending OTP' : 'Resend OTP',
                            style: TextStyle(
                              color: isRateLimited ? Colors.white38 : Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(duration: 1200.ms),
                        const SizedBox(height: 20),
                        if (errorMessage != null && state is AuthError && state.code == 'billing-not-enabled') ...[
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please contact support or check Firebase billing settings.'),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16),
                                ),
                              );
                            },
                            child: Text(
                              'Contact Support for Billing Issue',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).animate().fadeIn(duration: 1200.ms),
                        ],
                        if (errorMessage != null &&
                            state is AuthError &&
                            (state.code == 'session-expired' || state.code == 'invalid-verification-id')) ...[
                          const SizedBox(height: 16),
                          CustomButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                SendOtpEvent(phone: widget.phone, countryCode: widget.countryCode),
                              );
                            },
                            text: 'Request New OTP',
                            isLoading: state is AuthLoading,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}