import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../../../core/services/mqtt/app_message_dispatcher.dart';
import '../../../../core/widgets/glassy_wrapper.dart';
import '../../utils/pump_settings_dispatcher.dart';
import '../cubit/view_pump_settings_cubit.dart';

class ViewPumpSettingsPage extends StatelessWidget {
  final String deviceId;
  const ViewPumpSettingsPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = ViewPumpSettingsCubit();
        final dispatcher = PumpSettingsDispatcher(cubit);
        di.sl<AppMessageDispatcher>().pumpSettings = dispatcher;
        return cubit;
      },
      child: _ViewPumpSettingsView(deviceId: deviceId),
    );
  }
}

class _ViewPumpSettingsView extends StatelessWidget {
  final String deviceId;
  const _ViewPumpSettingsView({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ViewPumpSettingsCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.requestSettings(deviceId);
    });

    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("View Settings")),
        body: Center(
          child: BlocBuilder<ViewPumpSettingsCubit, ViewPumpSettingsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading pump settings..."),
                  ],
                );
              }

              if (state.errorMessage != null) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => cubit.requestSettings(deviceId),
                      child: Text("Retry"),
                    ),
                  ],
                );
              }

              if (state.settingsJson == null) {
                return const Text("No data received");
              }

              return Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    state.settingsJson!,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}