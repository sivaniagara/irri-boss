import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/mapped_node_entity.dart';
import 'report_menu_event.dart';

abstract class ReportMenuState extends Equatable {
  const ReportMenuState();

  @override
  List<Object?> get props => [];
}

class ReportMenuInitial extends ReportMenuState {}

class ReportMenuLoading extends ReportMenuState {}

class ReportMenuLoaded extends ReportMenuState {
  final List<MappedNodeEntity> mappedNodes;

  const ReportMenuLoaded({required this.mappedNodes});

  bool get hasMoisture => _hasCategory('moisture');
  bool get hasFertilizer => _hasCategory('fertilizer');
  bool get hasFogger => _hasCategory('fogger');
  bool get hasFlowMeter => _hasCategory('flowmeter');

  bool _hasCategory(String category) {
    return mappedNodes.any((node) => 
      node.categoryName.toLowerCase().replaceAll(' ', '').contains(category.toLowerCase()));
  }

  @override
  List<Object?> get props => [mappedNodes];
}

class ReportMenuError extends ReportMenuState {
  final String message;
  const ReportMenuError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportMenuNavigate extends ReportMenuState {
  final ReportType reportType;

  const ReportMenuNavigate(this.reportType);

  @override
  List<Object?> get props => [reportType];
}
