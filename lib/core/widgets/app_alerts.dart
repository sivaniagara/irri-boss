import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_material_button.dart';

void showLimitationAlert({required BuildContext context, required String message}){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xffCF2A2A),
                child: Icon(Icons.error_outline, size: 33, color: Colors.white,),
              ),
              Text(message, style: TextStyle(color: Colors.black, fontSize: 16),)
            ],
          ),
          actions: [
            CustomMaterialButton(
                onPressed: ()=> context.pop(),
                title: 'Ok'
            )
          ],
        );
      }
  );
}