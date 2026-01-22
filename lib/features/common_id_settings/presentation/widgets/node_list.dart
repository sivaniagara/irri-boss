import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_state.dart';

import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/custom_material_button.dart';
import '../../../../core/widgets/custom_outlined_button.dart';
import '../../domain/entities/category_node_entity.dart';
import '../bloc/common_id_settings_event.dart';

class NodeList extends StatefulWidget {
  final int categoryIndex;
  const NodeList({super.key, required this.categoryIndex});

  @override
  State<NodeList> createState() => _NodeListState();
}

class _NodeListState extends State<NodeList> {
  List<CategoryNodeEntity> listOfCategoryNode = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final commonIdSettingsLoaded = context.read<CommonIdSettingsBloc>().state as CommonIdSettingsLoaded;
    listOfCategoryNode = commonIdSettingsLoaded.listOfCategoryEntity[widget.categoryIndex].nodes.map((e) {
      return CategoryNodeEntity(
          nodeId: e.nodeId,
          categoryId: e.categoryId,
          categoryName: e.categoryName,
          qrCode: e.qrCode,
          nodeName: e.nodeName,
          serialNo: e.serialNo,
          orderNumber: e.orderNumber,
          serialNumbers: e.serialNumbers
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<CommonIdSettingsBloc, CommonIdSettingsState>(
      listener: (context, state){
      },
      child: BlocBuilder<CommonIdSettingsBloc, CommonIdSettingsState>(
        builder: (context, state) {
          final commonIdSettingsLoaded = state as CommonIdSettingsLoaded;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Nodes',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                      itemBuilder: (context, index){
                        CategoryNodeEntity categoryNodeEntity = listOfCategoryNode[index];
                        return ListTile(
                          key: ValueKey(categoryNodeEntity.nodeId), // ✅ stable & unique
                          title: Text(categoryNodeEntity.qrCode),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  categoryNodeEntity.serialNo,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.drag_handle), // 👈 drag icon
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: listOfCategoryNode.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = listOfCategoryNode.removeAt(oldIndex);
                        listOfCategoryNode.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.105,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomOutlinedButton(
                        onPressed: () {
                          context.pop();
                        },
                        title: 'Cancel',
                      ),
                      CustomMaterialButton(
                          onPressed: () {
                            context.read<CommonIdSettingsBloc>().add(EditNodesSerialNo(nodes: listOfCategoryNode, categoryIndex: widget.categoryIndex));
                          },
                          title: 'Send'
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
