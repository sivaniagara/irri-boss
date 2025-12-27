import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/standalone_bloc.dart';
import '../bloc/standalone_state.dart';
import '../bloc/standalone_event.dart';
import '../widgets/standalone_header.dart';
import '../widgets/zone_item.dart';

class ConfigurationPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ConfigurationPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "CONFIGURATION",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Top Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D9E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "STANDALONE",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "CONFIGURATION",
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Main Content
              Expanded(
                child: BlocConsumer<StandaloneBloc, StandaloneState>(
                  listener: (context, state) {
                    if (state is StandaloneSuccess) {
                      _showFloatingSnackBar(context, state.message);
                    } else if (state is StandaloneError) {
                      _showFloatingSnackBar(context, state.message, isError: true);
                    }
                  },
                  builder: (context, state) {
                    if (state is StandaloneLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (state is StandaloneLoaded || state is StandaloneSuccess) {
                      final standaloneData = (state is StandaloneLoaded) 
                          ? (state as StandaloneLoaded).data 
                          : (state as StandaloneSuccess).data;

                      final userId = data['userId']?.toString() ?? '';
                      final controllerId = data['controllerId']?.toString() ?? '';

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          // Top Part: Config mode and toggle
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Config mode",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                const Divider(color: Colors.grey, height: 1),
                                StandaloneHeader(
                                  title: "CONFIG MODE",
                                  isOn: standaloneData.settingValue == "1",
                                  onChanged: (v) {
                                    context.read<StandaloneBloc>().add(ToggleStandalone(v));
                                  },
                                  onSend: () {
                                    context.read<StandaloneBloc>().add(
                                           SendStandaloneConfigEvent(
                                             userId: userId,
                                             controllerId: controllerId,
                                             successMessage: "Config data sented successfully",
                                           ),
                                         );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Middle Part: Zones inside a specific white box with blue border
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF90CAF9), width: 2),
                            ),
                            child: Column(
                              children: [
                                ...standaloneData.zones.asMap().entries.map((entry) {
                                  return Column(
                                    children: [
                                      ZoneItem(index: entry.key, zone: entry.value),
                                      if (entry.key < standaloneData.zones.length - 1)
                                        const Divider(color: Colors.grey, height: 1, indent: 10, endIndent: 10),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          // SEND button below zones
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 36,
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                   context.read<StandaloneBloc>().add(
                                     SendStandaloneConfigEvent(
                                       userId: userId,
                                       controllerId: controllerId,
                                       successMessage: "Config data sented successfully",
                                     ),
                                   );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0288D1),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: const Text(
                                  "SEND", 
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    } else if (state is StandaloneError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
                    }
                    return const SizedBox();
                  },
                ),
              ),
              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF81B3F5).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Cancel", 
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            "View", 
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFloatingSnackBar(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.55,
        left: 50,
        right: 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? Colors.red.withValues(alpha: 0.9) : const Color(0xFF2E7D32).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}
