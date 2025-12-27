import 'package:flutter/material.dart';

class ListTileCard extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  const ListTileCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: Theme.of(context).listTileTheme.titleTextStyle,),
        trailing: Icon(Icons.keyboard_arrow_down, size: 32,),
      ),
    );
  }
}
