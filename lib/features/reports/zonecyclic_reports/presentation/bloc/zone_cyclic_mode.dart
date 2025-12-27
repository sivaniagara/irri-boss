import 'package:flutter_bloc/flutter_bloc.dart';

enum ZoneCyclicViewMode { report, zoneStatus }

class TdyValveViewState {
  final ZoneCyclicViewMode viewMode;
  final int selectedProgramIndex;

  const TdyValveViewState({
    this.viewMode = ZoneCyclicViewMode.zoneStatus,
    this.selectedProgramIndex = 0,
  });

  TdyValveViewState copyWith({
    ZoneCyclicViewMode? viewMode,
    int? selectedProgramIndex,
  }) {
    return TdyValveViewState(
      viewMode: viewMode ?? this.viewMode,
      selectedProgramIndex:
      selectedProgramIndex ?? this.selectedProgramIndex,
    );
  }
}

class ZoneCyclicCubit extends Cubit<TdyValveViewState> {
  ZoneCyclicCubit() : super(const TdyValveViewState());

  void toggleView() {
    emit(
      state.copyWith(
        viewMode:
        state.viewMode == ZoneCyclicViewMode.zoneStatus
            ? ZoneCyclicViewMode.report
            : ZoneCyclicViewMode.zoneStatus,
      ),
    );
  }
  void selectProgram(int index) {
    emit(state.copyWith(selectedProgramIndex: index));
  }
}
