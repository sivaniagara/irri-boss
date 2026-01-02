import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_service.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/publish_messages.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/node_status_entity.dart';
import '../../domain/usecases/get_node_status_usecase.dart';

abstract class NodeStatusState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NodeStatusInitialState extends NodeStatusState {}

class NodeStatusLoadedState extends NodeStatusState {
  final List<NodeStatusEntity> nodeStatusEntity;
  NodeStatusLoadedState({required this.nodeStatusEntity});

  @override
  List<Object?> get props => [nodeStatusEntity];
}

class NodeStatusFailure extends NodeStatusState {
  final String message;
  NodeStatusFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NodeStatusCubit extends Cubit<NodeStatusState> {
  final GetNodeStatusUsecase getNodeStatusUsecase;

  NodeStatusCubit({required this.getNodeStatusUsecase}) : super(NodeStatusInitialState());

  Future<void> getNodeStatus({required int userId, required int subUserId, required int controllerId, required String deviceId, bool isTestComm = false}) async {
    emit(NodeStatusInitialState());

    final result = await getNodeStatusUsecase(GetNodeStatusParams(
        userId: userId,
        controllerId: controllerId,
        subuserId: subUserId,
    ));

    sl.get<MqttService>().publish(
        deviceId,
        jsonEncode(
            isTestComm
                ? PublishMessageHelper.testCommunication
                : PublishMessageHelper.requestNodeStatus
        )
    );

    await Future.delayed(Duration(seconds: 2));
    result.fold(
          (failure) => emit(NodeStatusFailure(message: failure.message)),
          (nodeStatus) => emit(NodeStatusLoadedState(nodeStatusEntity: nodeStatus)),
    );
  }
}

