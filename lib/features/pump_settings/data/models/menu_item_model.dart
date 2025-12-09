import 'dart:convert';

import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/settings_menu_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/template_json_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  MenuItemModel({
    required super.menu,
    required super.template,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> staticJson) {
    return MenuItemModel(
        menu: SettingsMenuModel.fromJson(json),
        template: TemplateJsonModel.fromJson(jsonDecode(json['templateJson']), staticJson)
    );
  }
}