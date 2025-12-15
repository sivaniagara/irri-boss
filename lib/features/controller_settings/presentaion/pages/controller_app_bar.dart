import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/controller_settings_routes.dart';
import '../cubit/controller_tab_cubit.dart';
import '../widgets/zone_list.dart';

enum ControllerTab {details, nodes, programs}

extension ControllerTabExtension on ControllerTab{
  String title(){
    switch (this){
      case ControllerTab.details:
        return 'Controller';
      case ControllerTab.nodes:
        return 'Nodes';
      case ControllerTab.programs:
        return 'Programs';
      }
  }
}

class ControllerAppBar extends StatelessWidget {
  final Widget child;
  const ControllerAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONTROLLER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color(0xffC6DDFF),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 70),
          child: BlocBuilder<ControllerTabCubit, ControllerTabState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12,top: 12),
                child: Row(
                  spacing: 5,
                  children: [
                    getTabs(ControllerTab.details, context, state),
                    getTabs(ControllerTab.nodes, context, state),
                    getTabs(ControllerTab.programs, context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffC6DDFF),
                Color(0xff67C8F1),
                Color(0xff6DA8F5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
        ),
        child: child,
      ), // child comes from active GoRoute
    );
  }

  Widget getTabs(ControllerTab tab, BuildContext context, ControllerTabState state) {
    bool selected = tab == state.tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<ControllerTabCubit>().changeTab(tab);
          switch (tab) {
            case ControllerTab.details:
              context.go(ControllerSettingsRoutes.controllerDetails);
              break;
            case ControllerTab.nodes:
              context.go(ControllerSettingsRoutes.nodes);
              break;
            case ControllerTab.programs:
              context.go(ControllerSettingsRoutes.program);
              break;
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected ? Colors.white : Colors.transparent,
            border: !selected ? Border.all(color: Colors.grey) : null
          ),
          child: Center(child: Text(tab.title(), style: TextStyle(color: selected ? Theme.of(context).primaryColor : Colors.black, fontSize: 20, fontWeight: FontWeight.w500),)),
        ),
      ),
    );
  }
}



