import 'package:flutter_bloc/flutter_bloc.dart';

import '../enums/program_tab_enum.dart';


class ProgramTabState{
  final ProgramTabEnum tab;
  ProgramTabState(this.tab);
}


class ProgramTabCubit extends Cubit<ProgramTabState>{
  ProgramTabCubit() : super(ProgramTabState(ProgramTabEnum.p1));

  void changeTab(ProgramTabEnum newTab) {
    emit(ProgramTabState(newTab));
  }
}