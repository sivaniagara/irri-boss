import 'package:equatable/equatable.dart';

class GetMoistureParams extends Equatable {
  final int userId;
  final int subuserId;
  final int controllerId;

  const GetMoistureParams({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
   });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
   ];
}