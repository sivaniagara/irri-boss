import 'package:flutter/material.dart';
import 'dart:ui';

class GlassyAlertDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final List<Widget> actions;
  final bool barrierDismissible;
  final EdgeInsets? insetPadding;

  const GlassyAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.actions = const [],
    this.barrierDismissible = true,
    this.insetPadding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) => GlassyAlertDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: insetPadding ?? const EdgeInsets.all(32.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20.0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              // Content Section (Flexible for TextField, etc.)
              if (content != null) ...[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                    child: content!,
                  ),
                ),
              ],
              if (actions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions.map((action) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: action,
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}