import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/progam_zone_set/presentation/enums/program_tab_enum.dart';
import '../../../program_settings/utils/program_settings_routes.dart';
import '../../../water_fertilizer_settings/utils/water_fertilizer_settings_routes.dart';
import '../cubit/program_tab_cubit.dart';


class ProgramAppBar extends StatelessWidget {
  final Widget child;
  const ProgramAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color(0xffC6DDFF),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 70),
          child: BlocBuilder<ProgramTabCubit, ProgramTabState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 12, right: 12,top: 12),
                child: Row(
                  spacing: 5,
                  children: [
                    getTabs(ProgramTabEnum.p1, context, state),
                    getTabs(ProgramTabEnum.p2, context, state),
                    getTabs(ProgramTabEnum.p3, context, state),
                    getTabs(ProgramTabEnum.p4, context, state),
                    getTabs(ProgramTabEnum.p5, context, state),
                    getTabs(ProgramTabEnum.p6, context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: GradiantBackground(child: child), // child comes from active GoRoute
    );
  }

  Widget getTabs(ProgramTabEnum tab, BuildContext context, ProgramTabState state) {
    bool selected = tab == state.tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          switch (tab) {
            case ProgramTabEnum.p1:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '1')}');
              break;
            case ProgramTabEnum.p2:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '2')}');
              break;
            case ProgramTabEnum.p3:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '3')}');
              break;
            case ProgramTabEnum.p4:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '4')}');
              break;
            case ProgramTabEnum.p5:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '5')}');
              break;
            case ProgramTabEnum.p6:
              context.go('${DashBoardRoutes.dashboard}${IrrigationSettingsRoutes.irrigationSettings}${WaterFertilizerSettingsRoutes.program.replaceAll(':programId', '6')}');
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



