import 'package:equatable/equatable.dart';

class GetStandaloneParams extends Equatable {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const GetStandaloneParams({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
    fromDate,
    toDate,
  ];
}