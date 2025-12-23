import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import '../../domain/entities/node_entity.dart';
import '../enums/edit_zone_enums.dart';
import '../pages/edit_zone_page.dart';

class SelectableNodeList extends StatefulWidget {
  final NodeEntityMode nodeEntityMode;
  const SelectableNodeList({
    required this.nodeEntityMode,
    super.key,
  });

  @override
  State<SelectableNodeList> createState() => _SelectableNodeListState();
}

class _SelectableNodeListState extends State<SelectableNodeList> {

  late List<NodeEntity> tempNodes;

  @override
  void initState() {
    super.initState();

    final state = context.read<EditZoneBloc>().state as EditZoneLoaded;

    if (widget.nodeEntityMode == NodeEntityMode.valve) {
      tempNodes = state.zoneNodes.valves
          .map((e) => e.copyWith())
          .toList();
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<EditZoneBloc, EditZoneState>(
        listener: (context, state){
          if (state is EditValveLimitExceeded) {
            showErrorAlert(context: context, message: 'Maximum 4 valve should be able to select per zone.');
          }
        },
      child: BlocBuilder<EditZoneBloc, EditZoneState>(
        builder: (context, state) {
          if (state is EditZoneLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EditZoneLoaded) {
            List<NodeEntity> listOfNodeEntity = [];
            if(widget.nodeEntityMode == NodeEntityMode.valve){
              listOfNodeEntity = state.zoneNodes.valves;
            }
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Select Valves',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tempNodes.length,
                      itemBuilder: (context, index) {
                        final node = tempNodes[index];

                        return CheckboxListTile(
                          value: node.select,
                          title: Text('${node.nodeId}'),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Theme.of(context).primaryColor,
                          checkColor: Colors.white, side: const BorderSide( color: Colors.black, width: 2, ),
                          onChanged: (_) {
                            final selectedCount =
                                tempNodes.where((e) => e.select).length;

                            // 🚫 Max 4 rule
                            if (!node.select && selectedCount >= 4) {
                              showErrorAlert(context: context, message: 'Maximum 4 valve should be able to select per zone.');
                              return;
                            }

                            setState(() {
                              tempNodes[index] =
                                  node.copyWith(select: !node.select);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomOutlinedButton(
                            title: 'Cancel',
                            onPressed: (){
                              context.pop();
                            }
                        ),
                        CustomMaterialButton(
                          title: 'Apply',
                          onPressed: () {
                            context
                                .read<EditZoneBloc>()
                                .add(ApplyValveSelection(tempNodes));
                            context.pop();
                          },
                        ),

                      ],
                    ),
                  )
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
