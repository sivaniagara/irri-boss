import 'package:flutter/material.dart';

/// A configurable row widget that can display a label and value pair
/// with support for different display types like text, switches, and checkboxes
///
/// This widget is used throughout the app to maintain consistent styling
/// for configuration rows with labels and values

class ConfigRow extends StatelessWidget {
  final String? label;
  final String value;
  final bool highlight;
  final Pattern? splitBy;
  final bool? isBoolean;

  const ConfigRow({
    super.key,
    this.label,
    required this.value,
    this.highlight = false,
    this.splitBy,
    this.isBoolean = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: highlight ? Theme.of(context).primaryColor : Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        children: [
          if (label != null && label!.isNotEmpty)
            SizedBox(
              width: 120,
              child: Text(
                label!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          if (!(isBoolean ?? false))
            if (splitBy != null)
              for (int i = 0; i < value.split(splitBy!).length; i++)
                Expanded(
                  child: _buildContainer(
                    child: label == "Fertilizer"
                        ? Checkbox(
                            value: value.split(splitBy!)[i][1] == "1",
                            onChanged: (value) {},
                          )
                        : Text(
                            label == "Fertilizer"
                                ? value.split(splitBy!)[i][1]
                                : value.split(splitBy!)[i],
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                  ),
                )
            else
              Expanded(
                child: _buildContainer(
                  child: Text(
                    value,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          else
            Expanded(
              child: Switch(
                value: value == "1",
                onChanged: (newValue) {},
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
