import 'package:flutter/material.dart';


class WrapOrRow extends StatelessWidget {
  final bool open;
  final List<Widget> listOfWidget;
  const WrapOrRow({super.key, required this.open, required this.listOfWidget});

  @override
  Widget build(BuildContext context) {
    return open ? SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 10,
        children: listOfWidget,
      ),
    ) : SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 5,
        runSpacing: 10,
        children: listOfWidget,
      ),
    );
  }
}
