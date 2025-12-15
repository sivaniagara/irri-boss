import 'package:flutter/material.dart';

import '../../../../routes.dart';
import '../widgets/zone_list.dart';


class ControllerProgram extends StatelessWidget {
  const ControllerProgram({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
        itemBuilder: (context, index){
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: ListTile(
              onTap: (){
                showZoneBottomSheet(context);
              },
              title: Text('Program ${index+1}', style: Theme.of(context).listTileTheme.titleTextStyle,),
              trailing: Icon(Icons.keyboard_arrow_down, size: 32,),
            ),
          );
        }
    );
  }

  void showZoneBottomSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      // backgroundColor: Colors.white,x1
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) {
        return ZoneList();
      },
    );
  }
}
