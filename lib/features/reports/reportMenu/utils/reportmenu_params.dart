import 'package:equatable/equatable.dart';

class ReportmenuParams extends Equatable {
  final int userId;
  final int controllerId;
  final int subuserId;

  const ReportmenuParams({
    required this.userId,
    required this.controllerId,
    required this.subuserId,
  });

  @override
  List<Object?> get props => [userId, controllerId,subuserId];
}


