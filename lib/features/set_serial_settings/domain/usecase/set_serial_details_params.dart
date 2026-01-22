import 'package:equatable/equatable.dart';

class SetSerialParams extends Equatable {
  final int userId;
  final int controllerId;
  final int type;
  final String deviceId;


  const SetSerialParams({
    required this.userId,
    required this.controllerId,
    required this.type,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [userId, controllerId,type,deviceId];
}
