
import 'package:flutter_bloc/flutter_bloc.dart';



enum MotorCyclicViewMode { report, zoneStatus }

class MotorCyclicViewState {
  final MotorCyclicViewMode viewMode;
  final int selectedProgramIndex;

  const MotorCyclicViewState({
    this.viewMode = MotorCyclicViewMode.report,
    this.selectedProgramIndex = 0,
  });

  MotorCyclicViewState copyWith({
    MotorCyclicViewMode? viewMode,
    int? selectedProgramIndex,
  }) {
    return MotorCyclicViewState(
      viewMode: viewMode ?? this.viewMode,
      selectedProgramIndex:
      selectedProgramIndex ?? this.selectedProgramIndex,
    );
  }
}

class MotorCyclicViewCubit
    extends Cubit<MotorCyclicViewState> {
  MotorCyclicViewCubit()
      : super(const MotorCyclicViewState());

  void toggleView() {
    emit(
      state.copyWith(
        viewMode:
        state.viewMode == MotorCyclicViewMode.report
            ? MotorCyclicViewMode.zoneStatus
            : MotorCyclicViewMode.report,
      ),
    );
  }

  void selectProgram(int index) {
    emit(state.copyWith(selectedProgramIndex: index));
  }
}
