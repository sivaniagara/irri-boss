import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import '../cubit/selling_device_cubit.dart';
import '../cubit/selling_device_state.dart';

class TraceDevicePage extends StatefulWidget {
  const TraceDevicePage({super.key});

  @override
  State<TraceDevicePage> createState() => _TraceDevicePageState();
}

class _TraceDevicePageState extends State<TraceDevicePage> {
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellingDeviceCubit>().clearTrace();
    });
  }

  void _onTrace(String userId) {
    if (_deviceIdController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      context.read<SellingDeviceCubit>().traceDevice(userId, _deviceIdController.text);
    }
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = GoRouterState.of(context).uri.queryParameters;
    final userId = queryParams['userId'] ?? '153';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: const CustomAppBar(title: 'Add Controllers / Node'),
      body: BlocListener<SellingDeviceCubit, SellingDeviceState>(
        listener: (context, state) {
          if (state is SellingDeviceLoaded && state.message != null && state.message!.contains("successfully")) {
            _showSuccessPopup(context, state.message!);
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchCard(context, userId, theme),
              const SizedBox(height: 24),
              BlocBuilder<SellingDeviceCubit, SellingDeviceState>(
                builder: (context, state) {
                  if (state is SellingDeviceLoaded) {
                    if (state.isTraceLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state.traceError != null) {
                      return _errorCard(state.traceError!);
                    }

                    if (state.tracedDevice != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              "DEVICE IDENTITY FOUND",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.black45,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _deviceDetailsCard(context, state.tracedDevice!, userId, state),
                        ],
                      );
                    }
                  }
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.search_rounded, size: 64, color: theme.primaryColor.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        const Text(
                          "Ready to Trace",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black38),
                        ),
                        const Text(
                          "Enter a valid Device ID to verify details",
                          style: TextStyle(fontSize: 13, color: Colors.black26),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, String userId, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Device Verification",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track and authenticate your hardware",
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _deviceIdController,
            onSubmitted: (_) => _onTrace(userId),
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Device ID',
              labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w500),
              hintText: 'e.g. SN-98234-X',
              hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black26),
              filled: true,
              fillColor: const Color(0xffF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
              suffixIcon: _deviceIdController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                      onPressed: () {
                        _deviceIdController.clear();
                        context.read<SellingDeviceCubit>().clearTrace();
                        setState(() {});
                      },
                    )
                  : Icon(Icons.fingerprint_rounded, color: theme.primaryColor.withOpacity(0.3)),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _onTrace(userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: theme.primaryColor.withOpacity(0.4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radar_rounded, size: 20),
                  SizedBox(width: 10),
                  Text("TRACE HARDWARE", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Colors.green, size: 56),
              ),
              const SizedBox(height: 24),
              const Text("Authenticated", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SellingDeviceCubit>().clearMessage();
                    Navigator.of(dialogContext).pop();
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        border: Border.all(color: Colors.red.shade100, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceDetailsCard(BuildContext context, dynamic device, String userId, SellingDeviceLoaded state) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Specification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                        Text("Technical datasheet", style: TextStyle(fontSize: 11, color: Colors.black38)),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                _detailRow("Hardware Model", device.modelName, Icons.memory_rounded),
                _detailRow("Equipment Category", device.categoryName, Icons.category_rounded),
                _detailRow("Product Index", device.productId.toString(), Icons.tag_rounded),
                _detailRow("Assembly Date", device.dateManufacture, Icons.event_available_rounded),
                _detailRow("Warranty Cycle", "${device.warrentyMonths} Months", Icons.verified_user_rounded),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Text(
                    device.productDesc,
                    style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      context.read<SellingDeviceCubit>().clearTrace();
                      _deviceIdController.clear();
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black45,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("DISCARD", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: state.isAddingController
                        ? null
                        : () => context.read<SellingDeviceCubit>().addController(userId, device.productId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: theme.primaryColor.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.isAddingController
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("REGISTER DEVICE", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black26),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
