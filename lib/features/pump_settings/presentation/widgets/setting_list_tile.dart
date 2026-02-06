import 'package:flutter/material.dart';

import '../../utils/pump_settings_images.dart';

class SettingListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? leadingIcon;
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

    // print("leadingIcon :: $leadingIcon");
    return ListTile(
      leading: leadingIcon !=null ? Image.asset(leadingIcon!, width: 22, height: 22,) : null,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
      )
          : null,
      trailing: IntrinsicWidth(child: trailingWidget),
      onTap: onTap,
      minTileHeight: 45,
      contentPadding: EdgeInsets.symmetric(horizontal: leadingIcon != null ? 5 : 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minVerticalPadding: 0,
    );
  }
}