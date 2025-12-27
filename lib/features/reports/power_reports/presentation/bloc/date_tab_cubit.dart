
import 'package:flutter_bloc/flutter_bloc.dart';

enum DateTabType { days, weekly, monthly }

class DateTabCubit extends Cubit<DateTabType> {
  DateTabCubit() : super(DateTabType.days);

  void selectDays() => emit(DateTabType.days);
  void selectWeekly() => emit(DateTabType.weekly);
  void selectMonthly() => emit(DateTabType.monthly);
}