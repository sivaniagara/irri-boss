import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/widgets/custom_card.dart';

import '../../domain/entities/zone_setting_entity.dart';
import '../bloc/edit_program_bloc.dart';

enum PayloadModeEnum {idle, loading, success, failure}

class PayloadPage extends StatefulWidget {
  final int channelNo;
  final int irrigationDosingOrPrePost;
  final int method;
  const PayloadPage({
    super.key,
    required this.channelNo,
    required this.irrigationDosingOrPrePost,
    required this.method,
  });

  @override
  State<PayloadPage> createState() => _PayloadPageState();
}

class _PayloadPageState extends State<PayloadPage> {
  late List<Map<String, dynamic>> zoneSetSelection;
  late List<Map<String, dynamic>> zoneSelection;
  bool enableEdit = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    zoneSelection = (context.read<EditProgramBloc>().state as EditProgramLoaded).editProgramEntity.zones
        .map((e) => {'mode' : PayloadModeEnum.idle, 'value' : true}).toList();
    zoneSetSelection = splitIntoChunks(8);
  }

  List<Map<String, dynamic>> splitIntoChunks(int chunkSize) {
    List<Map<String, dynamic>> chunks = [];
    for (var i = 0; i < zoneSelection.length; i += chunkSize) {
      chunks.add({'mode' : PayloadModeEnum.idle, 'value' : true});
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProgramBloc, EditProgramState>(
        builder: (context, state){
          if(state is EditProgramLoaded){
            return SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zone Configuration', style: Theme.of(context).textTheme.labelLarge,),
                            ...List.generate(zoneSelection.length, (index){
                              final zone = state.editProgramEntity.zones[index];
                              return CheckboxListTile(
                                enabled: enableEdit,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: Text('Block ${zone.zoneNumber}'),
                                  value: zoneSelection[index]['value'],
                                  onChanged: (value){
                                    setState(() {
                                      zoneSelection[index]['value'] = value;
                                    });
                                  },
                                activeColor: Colors.green,
                                secondary: getStatusWidget(zoneSelection[index]['mode']),
                              );
                            }),
                            Text('Zone Set Setting', style: Theme.of(context).textTheme.labelLarge,),
                            ...List.generate(zoneSetSelection.length, (index){
                              return CheckboxListTile(
                                enabled: enableEdit,
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text('Block set ${index+1}'),
                                value: zoneSetSelection[index]['value'],
                                onChanged: (value){
                                  setState(() {
                                    zoneSetSelection[index]['value'] = value;
                                  });
                                },
                                activeColor: Colors.green,
                                secondary: getStatusWidget(zoneSetSelection[index]['mode']),
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomOutlinedButton(
                            title: 'Cancel',
                            onPressed: (){
                              context.pop();
                            }
                        ),
                        CustomMaterialButton(
                            onPressed: () async {
                              enableEdit = false;
                              setState(() {});
                              for (var zonePayload = 0; zonePayload < zoneSelection.length; zonePayload++) {
                                if(!zoneSelection[zonePayload]['value']) continue;
                                setState(() {
                                  zoneSelection[zonePayload]['mode'] = PayloadModeEnum.loading;
                                });

                                try {
                                  final result = await context.read<EditProgramBloc>().sendZonePayload(
                                    zoneIndex: zonePayload,
                                  );
                                  setState(() {
                                    zoneSelection[zonePayload]['mode'] = result; // ← now result is the real enum value
                                  });
                                } catch (e) {
                                  setState(() {
                                    zoneSelection[zonePayload]['mode'] = PayloadModeEnum.failure;
                                  });
                                  print("Zone $zonePayload failed: $e");
                                }
                              }
                              for (var zoneSetPayload = 0; zoneSetPayload < zoneSetSelection.length; zoneSetPayload++) {
                                if(!zoneSetSelection[zoneSetPayload]['value']) continue;
                                setState(() {
                                  zoneSetSelection[zoneSetPayload]['mode'] = PayloadModeEnum.loading;
                                });

                                try {
                                  final result = await context.read<EditProgramBloc>().sendZoneSetPayload(
                                    zoneSetNo: zoneSetPayload + 1,
                                    channelNo: widget.channelNo,
                                    irrigationDosingOrPrePost: widget.irrigationDosingOrPrePost,
                                    method: widget.method,
                                  );
                                  setState(() {
                                    zoneSetSelection[zoneSetPayload]['mode'] = result; // ← now result is the real enum value
                                  });
                                } catch (e) {
                                  setState(() {
                                    zoneSetSelection[zoneSetPayload]['mode'] = PayloadModeEnum.failure;
                                  });
                                  print("Zone $zoneSetPayload failed: $e");
                                }
                              }
                            },
                            title: 'Send'
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }else{
            return Placeholder();
          }
        },
        listener: (context, state){}
    );
  }

  Widget getStatusWidget(PayloadModeEnum payloadModeEnum) {
    switch (payloadModeEnum) {
      case PayloadModeEnum.loading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        );
      case PayloadModeEnum.success:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 26,
        );
      case PayloadModeEnum.failure:
        return const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 26,
        );
      default:
        return const SizedBox(width: 26);
    }
  }
}