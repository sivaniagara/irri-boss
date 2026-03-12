import '../../domain/entities/category_node_entity.dart';

abstract class CommonIdSettingsEvent{}

class FetchCommonIdSettings extends CommonIdSettingsEvent{
  final String userId;
  final String controllerId;
  final String deviceId;
  FetchCommonIdSettings({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
  });
}

class EditNodesSerialNo extends CommonIdSettingsEvent {
  final int categoryIndex;
  final List<CategoryNodeEntity> nodes;
  EditNodesSerialNo({required this.nodes, required this.categoryIndex});
}

class ViewCommonIdEvent extends CommonIdSettingsEvent {
  final int categoryIndex;
  ViewCommonIdEvent({required this.categoryIndex});
}
class ResetCommonIdEvent extends CommonIdSettingsEvent {
  final int categoryIndex;
  final List<CategoryNodeEntity> listOfCategoryNodeEntity;
  ResetCommonIdEvent({required this.categoryIndex, required this.listOfCategoryNodeEntity});
}