import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TinyTextFormField extends StatefulWidget {
  final String value;                    // External value (can change)
  final ValueChanged<String>? onChanged; // Optional callback
  final ValueChanged<String>? onSubmitted;
  List<TextInputFormatter>? inputFormatters;

  TinyTextFormField({
    super.key,
    required this.value,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters
  });

  @override
  State<TinyTextFormField> createState() => _TinyTextFormFieldState();
}

class _TinyTextFormFieldState extends State<TinyTextFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant TinyTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if external value actually changed
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;

      // Optional: Preserve cursor at end
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,  // Use controller, not initialValue
      inputFormatters: widget.inputFormatters,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        suffix: Text('L', style: TextStyle(color: Theme.of(context).colorScheme.outline,)),
        border: InputBorder.none,           // Disables outline border
        enabledBorder: InputBorder.none,    // Disables border when enabled
        focusedBorder: InputBorder.none,     // Disables border when focused
        disabledBorder: InputBorder.none,   // (optional)
        errorBorder: InputBorder.none,       // (if you use validation)
        focusedErrorBorder: InputBorder.none,
        // This is the key: removes the default underline
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}