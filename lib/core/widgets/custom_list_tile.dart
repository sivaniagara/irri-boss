import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  void Function()? onTap;
  final String title;
  CustomListTile({
    super.key,
    required this.onTap,
    required this.title
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
        onTap: onTap,
        title: Text(
          title,
          style: Theme.of(context)
              .listTileTheme
              .titleTextStyle,
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          size: 32,
        ),
      ),
    );
  }
}
