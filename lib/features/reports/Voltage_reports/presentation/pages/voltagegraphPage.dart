// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_event.dart';
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_state.dart';
//
//
// class VoltageGraphPage extends StatelessWidget {
//
//    final Map<String, dynamic> params;
//
//   const VoltageGraphPage({
//     super.key,
//     required this.params,
//   });
//    Future<void> _selectDate(BuildContext context) async {
//      final selectedDate = await showDatePicker(
//        context: context,
//        initialDate: DateTime.now(),
//        firstDate: DateTime(2020),
//        lastDate: DateTime.now(),
//      );
//
//      if (selectedDate != null) {
//        final formattedDate =
//        DateFormat('yyyy-MM-dd').format(selectedDate);
//
//        context.read<VoltageGraphBloc>().add(
//          LoadVoltageGraphEvent(
//            userId: params["userId"],
//            subuserId: params["subuserId"] ?? 0,
//            controllerId: params["controllerId"],
//            fromDate: formattedDate,
//            toDate: formattedDate, // same date load
//          ),
//        );
//      }
//    }
//   @override
//   Widget build(BuildContext context) {
//
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Send and Receive"),
//         actions: [
//         IconButton(
//           icon: const Icon(Icons.calendar_today),
//           onPressed: () => _selectDate(context),
//         ),
//       ],),
//       body: BlocBuilder<VoltageGraphState, VoltageGraphState>(
//         builder: (context, state) {
//           if (state is VoltageGraphLoaded) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is VoltageGraphLoaded) {
//             return ListView ();
//           }
//            if (state is VoltageGraphError) {
//             return Center(child: Text(state.toString(),style: TextStyle(color: Colors.black),));
//           }
//
//           return const SizedBox();
//         },
//       ),
//     );
//   }
// }
