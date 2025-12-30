import '../../../core/services/mqtt/mqtt_message_helper.dart';
import '../domain/entities/livemessage_entity.dart';
import '../presentation/bloc/dashboard_bloc.dart';
import '../presentation/bloc/dashboard_event.dart';

class DashboardMessageDispatcher extends MessageDispatcher {
  final DashboardBloc dashboardBloc;

  DashboardMessageDispatcher({required this.dashboardBloc});

  @override
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage) {
    dashboardBloc.add(UpdateLiveMessageEvent(deviceId, liveMessage));
  }
}