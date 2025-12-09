import 'package:flutter/material.dart';

class SettingListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final double? iconSize;

  final bool hasSendButton;
  final VoidCallback? onSendPressed;

  const SettingListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconSize,
    this.hasSendButton = false,
    this.onSendPressed,
  });

  @override
  Widget build(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);

    Widget? trailingWidget;

    if (hasSendButton) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          if (trailing != null) const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: onSendPressed,
              icon: Icon(Icons.send, color: theme.primaryColor),
              tooltip: "Send",
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    } else {
      trailingWidget = trailing ??
          (onTap != null
              ? Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          )
              : null);
    }

    return ListTile(
      leading: leadingIcon != null
          ? Icon(
        leadingIcon,
        color: iconColor ?? theme.colorScheme.primary,
        size: iconSize ?? 28,
      )
          : null,
      title: Text(
        title,
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        // style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      )
          : null,
      trailing: IntrinsicWidth(child: trailingWidget),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minVerticalPadding: 0,
    );
  }
}