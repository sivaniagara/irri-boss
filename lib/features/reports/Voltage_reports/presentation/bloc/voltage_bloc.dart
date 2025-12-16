// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_event.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_state.dart' show VoltageGraphState, VoltageGraphInitial, VoltageGraphLoading, VoltageGraphLoaded, VoltageGraphError;
//
// import '../../domain/entities/voltage_entities.dart';
// import '../../domain/usecases/voltage_params.dart';
// import '../../domain/usecases/voltageparams.dart';
//
//
// class VoltageGraphBloc extends Bloc<VoltageGraphEvent, VoltageGraphState> {
//   final GetVoltGraphParams fetchvoltgraphdata;
//
//   VoltageGraphBloc({required this.fetchvoltgraphdata})
//       : super(VoltageGraphInitial()) {
//     on<LoadVoltageGraphEvent>(_onLoadData);
//   }
//
//
//   Future<void> _onLoadData(
//       LoadVoltageGraphEvent event, Emitter<VoltageGraphState> emit) async {
//     emit(VoltageGraphLoading());
//     try {
//       // Call the use case with parameters from the event
//       final result = await FetchVoltageGraphData.call(
//         userId: event.userId,
//         subuserId: event.subuserId,
//         controllerId: event.controllerId,
//         fromDate: event.fromDate,
//         toDate: event.toDate,
//       );
//
//       // result is SendrevEntity, now we can access .data
//       emit(VoltageGraphLoaded(result.data));
//     } catch (e) {
//       emit(VoltageGraphError(e.toString()));
//     }
//   }
//
// }
