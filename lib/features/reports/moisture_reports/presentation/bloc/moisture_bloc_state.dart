import 'package:equatable/equatable.dart';
import '../../domain/entities/moisture_entities.dart';

abstract class MoistureState extends Equatable {
  const MoistureState();

  @override
  List<Object?> get props => [];
}

/// Initial
class MoistureInitial extends MoistureState {}

/// Loading
class MoistureLoading extends MoistureState {}

/// Success
class MoistureLoaded extends MoistureState {
  final MoistureEntity data;

  const MoistureLoaded({
    required this.data,
  });

  @override
  List<Object?> get props => [data];
}

/// Error
class MoistureError extends MoistureState {
  final String message;

  const MoistureError(this.message);

  @override
  List<Object?> get props => [message];
}