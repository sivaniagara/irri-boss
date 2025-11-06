import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LiveDisplayObject extends StatelessWidget {
  final String disMsg1;
  final String disValues1;
  final String disMsg2;
  final String disValues2;

  const LiveDisplayObject({
    super.key,
    required this.disMsg1,
    required this.disValues1,
    required this.disMsg2,
    required this.disValues2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
       child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Expanded(child: _buildDisplayItem(disMsg1, disValues1)),
           Expanded(child: _buildDisplayItem(disMsg2, disValues2)),
        ],
      ),
    );
  }

  Widget _buildDisplayItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
       mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "$label :",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
             ),
          ),
        ),
      ],
    );
  }
}

