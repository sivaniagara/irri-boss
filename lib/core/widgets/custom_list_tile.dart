import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/app_images.dart';

class CustomListTile extends StatelessWidget {
  void Function()? onTap;
  IconData? iconData;
  final String title;
  String? image;
  CustomListTile({
    super.key,
    this.iconData,
    required this.onTap,
    required this.title,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: image != null ? Image.asset(
            image!,
          width: 25,
          height: 25,
        ) : null,
        onTap: onTap,
        title: Text(
          title,
          style: Theme.of(context)
              .listTileTheme
              .titleTextStyle,
        ),
        trailing: Icon(
          iconData ?? Icons.keyboard_arrow_down,
          size: 32,
        ),
      ),
    );
  }
}
