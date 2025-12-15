import 'package:equatable/equatable.dart';

class GetControllerDetailsParams extends Equatable {
  final int userId;
  final int controllerId;

  const GetControllerDetailsParams({
    required this.userId,
    required this.controllerId,
  });

  @override
  List<Object?> get props => [userId, controllerId];
}
