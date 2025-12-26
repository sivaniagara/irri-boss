import 'package:flutter/material.dart';

/// A grid-based configuration row widget that displays multiple values in a grid layout
///
/// This widget is used to display related configuration values in a compact
/// grid format, with column labels and corresponding values

class ConfigGridRow extends StatelessWidget {
  final String? label;
  final List<String> values;
  final List<String> columnLabels;

  const ConfigGridRow({
    super.key,
    this.label,
    required this.values,
    required this.columnLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: columnLabels.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    columnLabels[index],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    values[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
