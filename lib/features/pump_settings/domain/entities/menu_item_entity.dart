// features/pump_settings/domain/entities/menu_item_entity.dart

import 'package:collection/collection.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/settings_menu_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

class MenuItemEntity {
  final SettingsMenuEntity menu;
  final TemplateJsonEntity template;

  const MenuItemEntity({
    required this.menu,
    required this.template,
  });

  /// Creates a copy with optionally updated fields
  MenuItemEntity copyWith({
    SettingsMenuEntity? menu,
    TemplateJsonEntity? template,
  }) {
    return MenuItemEntity(
      menu: menu ?? this.menu,
      template: template ?? this.template,
    );
  }

  /// Useful when you want to update a specific setting value inside the template
  MenuItemEntity copyWithSettingValue({
    required int serialNumber,
    required String newValue,
  }) {
    final updatedSections = template.sections.map((section) {
      return section.copyWithSetting(serialNumber, newValue);
    }).toList();

    return copyWith(
      template: template.copyWith(sections: updatedSections),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MenuItemEntity &&
              runtimeType == other.runtimeType &&
              menu == other.menu &&
              template == other.template;

  @override
  int get hashCode => Object.hash(menu, template);

  @override
  String toString() {
    return 'MenuItemEntity(menu: ${menu.templateName}, templateType: ${template.type})';
  }
}