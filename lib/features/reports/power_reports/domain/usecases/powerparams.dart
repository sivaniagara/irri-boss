import 'package:equatable/equatable.dart';

class GetVoltGraphParams extends Equatable {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;
  final int sum;

  const GetVoltGraphParams({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
    required this.sum,
  });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
    fromDate,
    toDate,
    sum,
  ];
}