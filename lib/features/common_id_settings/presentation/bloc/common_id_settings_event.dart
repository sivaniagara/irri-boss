import '../../domain/entities/category_node_entity.dart';

abstract class CommonIdSettingsEvent{}

class FetchCommonIdSettings extends CommonIdSettingsEvent{
  final String userId;
  final String controllerId;
  FetchCommonIdSettings({required this.userId, required this.controllerId});
}

class EditNodesSerialNo extends CommonIdSettingsEvent {
  final int categoryIndex;
  final List<CategoryNodeEntity> nodes;
  EditNodesSerialNo({required this.nodes, required this.categoryIndex});
}
