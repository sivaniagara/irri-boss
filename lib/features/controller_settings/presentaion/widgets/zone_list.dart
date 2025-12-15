import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_outlined_button.dart';

class ZoneList extends StatelessWidget {
  const ZoneList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Zones', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22),),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: 5,
                itemBuilder: (context, int index){
                  return ListTile(
                    title: Text('Zone ${index+1}', style: Theme.of(context).listTileTheme.titleTextStyle,),
                    trailing: IconButton(
                        onPressed: (){

                        },
                        icon: Icon(Icons.send_outlined, color: Theme.of(context).primaryColor,),
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xffEDF8FF))),
                    )
                  );
                }
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomOutlinedButton(
                  title: 'Cancel',
                  onPressed: (){

                  }
              ),
              CustomMaterialButton(
                  onPressed: (){

                  },
                  title: 'Add Zone'
              )
            ],
          )
        ],
      ),
    );
  }
}
