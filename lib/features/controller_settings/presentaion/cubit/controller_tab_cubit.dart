import '../pages/controller_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ControllerTabState{
  final ControllerTab tab;
  ControllerTabState(this.tab);
}


class ControllerTabCubit extends Cubit<ControllerTabState>{
  ControllerTabCubit() : super(ControllerTabState(ControllerTab.programs));

  void changeTab(ControllerTab newTab) {
    emit(ControllerTabState(newTab));
  }
}