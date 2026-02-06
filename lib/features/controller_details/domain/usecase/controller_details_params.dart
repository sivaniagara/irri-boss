import 'package:equatable/equatable.dart';

class GetControllerDetailsParams extends Equatable {
  final int userId;
  final int controllerId;
  final String deviceId;

  const GetControllerDetailsParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [userId, controllerId,deviceId];
}
