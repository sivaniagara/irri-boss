 
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/entities/voltage_entities.dart';

abstract class VoltageGraphState {}

class VoltageGraphInitial extends VoltageGraphState {}

class VoltageGraphLoading extends VoltageGraphState {}

class VoltageGraphLoaded extends VoltageGraphState {
  final List<VoltageDatum> voltGraphData;

  VoltageGraphLoaded(this.voltGraphData);
}

class VoltageGraphError extends VoltageGraphState {
  final String voltGraphData;

  VoltageGraphError(this.voltGraphData);
}
