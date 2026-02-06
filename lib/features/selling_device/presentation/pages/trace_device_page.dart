import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    // Clear any previous trace results when entering the page
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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Trace Device'),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffC6DDFF),
              Color(0xff67C8F1),
              Color(0xff6DA8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocListener<SellingDeviceCubit, SellingDeviceState>(
          listener: (context, state) {
            if (state is SellingDeviceLoaded && state.message != null && state.message!.contains("successfully")) {
              _showSuccessPopup(context, state.message!);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _deviceIdController,
                          onSubmitted: (_) => _onTrace(userId),
                          decoration: InputDecoration(
                            labelText: 'Device ID',
                            hintText: 'Enter device ID',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: _deviceIdController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: Colors.grey),
                              onPressed: () {
                                _deviceIdController.clear();
                                context.read<SellingDeviceCubit>().clearTrace();
                                setState(() {}); // Refresh to hide icon
                              },
                            )
                                : null,
                          ),
                          onChanged: (val) => setState(() {}), // Show/hide cancel icon
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _onTrace(userId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("TRACE DEVICE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<SellingDeviceCubit, SellingDeviceState>(
                  builder: (context, state) {
                    if (state is SellingDeviceLoaded) {
                      if (state.isTraceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.traceError != null) {
                        return _errorCard(state.traceError!);
                      }

                      if (state.tracedDevice != null) {
                        return _deviceDetailsCard(context, state.tracedDevice!, userId, state);
                      }
                    }
                    return const Center(child: Text("Enter Device ID to see details", style: TextStyle(color: Colors.white70)));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
              const SizedBox(height: 20),
              const Text("Success", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SellingDeviceCubit>().clearMessage();
                    Navigator.of(dialogContext).pop();
                    context.pop(); // Exit back to inventory
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String error) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.red, width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceDetailsCard(BuildContext context, dynamic device, String userId, SellingDeviceLoaded state) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    const Text("Product Available", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Divider(height: 32),
                _detailRow("Model Name", device.modelName),
                _detailRow("Category", device.categoryName),
                _detailRow("Product ID", device.productId.toString()),
                _detailRow("Manufacturing Date", device.dateManufacture),
                _detailRow("Warranty", "${device.warrentyMonths} Months"),
                const SizedBox(height: 16),
                Text(device.productDesc, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: state.isAddingController
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SUBMIT", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
