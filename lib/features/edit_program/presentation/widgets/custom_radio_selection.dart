import 'package:flutter/material.dart';

class CustomRadioSelection extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final bool selected;
  const CustomRadioSelection({
    super.key,
    required this.title, required this.selected, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          spacing: 10,
          children: [
            Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: Color(0xff0B9E19),),
            Text(title, style: Theme.of(context).textTheme.labelLarge,)
          ],
        ),
      ),
    );
  }
}
