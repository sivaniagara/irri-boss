
import 'package:flutter_bloc/flutter_bloc.dart';

class DaySelectionState {
  List<String> selectedDays;
  DaySelectionState({required this.selectedDays});
}

class DaySelectionCubit extends Cubit<DaySelectionState> {
  DaySelectionCubit() : super(DaySelectionState(selectedDays: []));

  void addAndRemove(String day) {
    final updatedDays = List<String>.from(state.selectedDays);
    if (updatedDays.contains(day)) {
      updatedDays.remove(day);
    } else {
      updatedDays.add(day);
    }
    emit(DaySelectionState(selectedDays: updatedDays));
  }

}