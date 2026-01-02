import 'package:flutter_bloc/flutter_bloc.dart';

enum TdyValveStatusViewMode { report, zoneStatus }

class TdyValveViewState {
  final TdyValveStatusViewMode viewMode;
  final int selectedProgramIndex;

  const TdyValveViewState({
    this.viewMode = TdyValveStatusViewMode.zoneStatus,
    this.selectedProgramIndex = 0,
  });

  TdyValveViewState copyWith({
    TdyValveStatusViewMode? viewMode,
    int? selectedProgramIndex,
  }) {
    return TdyValveViewState(
      viewMode: viewMode ?? this.viewMode,
      selectedProgramIndex:
      selectedProgramIndex ?? this.selectedProgramIndex,
    );
  }
}

class TdyValveStatusCubit extends Cubit<TdyValveViewState> {
  TdyValveStatusCubit() : super(const TdyValveViewState());

  void toggleView() {
    emit(
      state.copyWith(
        viewMode:
        state.viewMode == TdyValveStatusViewMode.zoneStatus
            ? TdyValveStatusViewMode.report
            : TdyValveStatusViewMode.zoneStatus,
      ),
    );
  }
  void selectProgram(int index) {
    emit(state.copyWith(selectedProgramIndex: index));
  }
}
