import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/gradiant_background.dart';

class TemplateSetting extends StatelessWidget {
  final String appBarTitle;
  const TemplateSetting({super.key, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: appBarTitle),
      body: GradiantBackground(
          child: Column(
            children: [

            ],
          )
      ),
    );
  }
}
