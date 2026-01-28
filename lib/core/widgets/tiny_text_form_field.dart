import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class TinyTextFormField extends StatefulWidget {
  final String value;                    // External value (can change)
  final ValueChanged<String>? onChanged; // Optional callback
  final ValueChanged<String>? onSubmitted;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;

  const TinyTextFormField({
    super.key,
    required this.value,
    this.onChanged,
    this.onSubmitted,
    this.suffixText,
    this.inputFormatters
  });

  @override
  State<TinyTextFormField> createState() => _TinyTextFormFieldState();
}

class _TinyTextFormFieldState extends State<TinyTextFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
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
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,  // Use controller, not initialValue
      focusNode: _focusNode,
      inputFormatters: widget.inputFormatters,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center, // Centering the text
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        suffixText: _isFocused ? widget.suffixText : null,
        suffixStyle: TextStyle(color: Theme.of(context).colorScheme.outline,),
        border: InputBorder.none,           // Disables outline border
        enabledBorder: InputBorder.none,    // Disables border when enabled
        focusedBorder: InputBorder.none,     // Disables border when focused
        disabledBorder: InputBorder.none,   // (optional)
        errorBorder: InputBorder.none,       // (if you use validation)
        focusedErrorBorder: InputBorder.none,
        // This is the key: removes the default underline
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4, // Adjusted for centering
          vertical: 8,
        ),
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}