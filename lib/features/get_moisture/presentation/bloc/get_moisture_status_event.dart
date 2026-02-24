import 'package:equatable/equatable.dart';

abstract class GetMoistureStatusEvent extends Equatable {
  const GetMoistureStatusEvent();

  @override
  List<Object> get props => [];
}

class FetchGetMoistureStatus extends GetMoistureStatusEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchGetMoistureStatus({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object> get props => [userId, subuserId, controllerId, fromDate, toDate];
}
