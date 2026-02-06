import 'dart:convert';
import 'dart:developer';

import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/notifications_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/template_json_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/notifications_entity.dart';

import '../../domain/entities/menu_item_entity.dart';
import '../models/menu_item_model.dart';
import '../models/settings_menu_model.dart';
import '../../utils/pump_settings_urls.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../domain/entities/settings_menu_entity.dart';

import '../../../../core/services/api_client.dart';

abstract class PumpSettingsDataSources {
  Future<List<MenuItemEntity>> getSettingsMenuList(int userId, int subuserId, int controllerId);
  Future<MenuItemEntity> getPumpSettings(int userId, int subuserId, int controllerId, int menuId);
  Future<List<NotificationsEntity>> getNotifications(int userId, int subuserId, int controllerId);
  Future<String> subscribeNotifications(int userId, int subuserId, int controllerId, Map<String, dynamic> body);
  Future<String> sendPumpSettings(int userId, int subUserId, int controllerId, MenuItemEntity menuItem, String sentSms);
  Future<String> updateMenuStatus(int userId, int subUserId, int controllerId, SettingsMenuEntity menu);
}

class PumpSettingsDataSourcesImpl implements PumpSettingsDataSources {
  final ApiClient apiClient;
  PumpSettingsDataSourcesImpl({required this.apiClient});

  Map<String, dynamic> _baseParams({
    required int userId,
    required int subuserId,
    required int controllerId,
    int? menuId,
  }) {
    return {
      "userId": userId,
      "subuserId": subuserId,
      "controllerId": controllerId,
      if (menuId != null) "menuId": menuId,
    };
  }

  @override
  Future<List<MenuItemEntity>> getSettingsMenuList(int userId, int subuserId, int controllerId) async{
    try {
      final endPoint = buildUrl(
          PumpSettingsUrls.getSettingsMenu,
          _baseParams(userId: userId, controllerId: controllerId, subuserId: 0)
      );
      final response = await apiClient.get(endPoint);
      return handleListResponse<MenuItemModel>(response, fromJson: (json) => MenuItemModel.fromJson(json))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (groups) => groups.cast<MenuItemEntity>(),
      );
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity> getPumpSettings(int userId, int subuserId, int controllerId, int menuId) async {
    try {
      final endPoint = buildUrl(
          PumpSettingsUrls.getFinalMenu,
          _baseParams(userId: userId, controllerId: controllerId, subuserId: 0, menuId: menuId)
      );

      final response = await apiClient.get(endPoint);

      return handleApiResponse<MenuItemEntity>(response, parser: (dynamic data) => MenuItemModel.fromJson(data[0]))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (menuItem) => menuItem,
      );
    } catch (e, s) {
      log('getPumpSettings error :: $e');
      log('getPumpSettings stacktrace :: $s');
      rethrow;
    }
  }

  @override
  Future<List<NotificationsEntity>> getNotifications(int userId, int subuserId, int controllerId) async {
    try {
      final endPoint = buildUrl(
          PumpSettingsUrls.getNotificationSettings,
          _baseParams(userId: userId, controllerId: controllerId, subuserId: 0)
      );

      final response = await apiClient.get(endPoint);

      return handleListResponse<NotificationsModel>(response, fromJson: (json) => NotificationsModel.fromJson(json))
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (notifications) => notifications.cast<NotificationsModel>(),
      );
    } catch (e, s) {
      log('getNotifications error :: $e');
      log('getNotifications stacktrace :: $s');
      rethrow;
    }
  }

  @override
  Future<String> subscribeNotifications(int userId, int subuserId, int controllerId, Map<String, dynamic> body) async {
    try {
      final endPoint = buildUrl(
          PumpSettingsUrls.getNotificationSettings,
          _baseParams(userId: userId, controllerId: controllerId, subuserId: 0),
      );

      final response = await apiClient.put(endPoint, body: body);

      return handleApiResponse<String>(response, parser: (dynamic data) => data, returnMessageOnNoData: true)
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (result) => result,
      );
    } catch (e, s) {
      log('subscribeNotifications error :: $e');
      log('subscribeNotifications stacktrace :: $s');
      rethrow;
    }
  }

  @override
  Future<String> sendPumpSettings(int userId, int subUserId, int controllerId, MenuItemEntity menuItem, String sentSms) async {
    try {
      final endPoint = buildUrl(
          PumpSettingsUrls.updateTemplate,
          _baseParams(userId: userId, controllerId: controllerId, subuserId: 0),
      );
      final TemplateJsonModel templateJsonModel = TemplateJsonModel.fromEntity(menuItem.template);
      final Map<String, dynamic> template = templateJsonModel.toJson();

      final Map<String, dynamic> body = {
        "sendData": jsonEncode(template),
        "receivedData": "",
        "menuSettingId": menuItem.menu.menuSettingId,
        "sentSms": sentSms
      };

      final response = await apiClient.post(endPoint, body: body);

      return handleApiResponse(response, parser: (dynamic data) => data, returnMessageOnNoData: true)
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (message) => message,
      );
    } catch (e, s) {
      log('sendPumpSettings error :: $e');
      log('sendPumpSettings stacktrace :: $s');
      rethrow;
    }
  }

  @override
  Future<String> updateMenuStatus(int userId, int subUserId, int controllerId, SettingsMenuEntity menu) async{
    try {
      final endPoint = buildUrl(
        PumpSettingsUrls.getSettingsMenu,
        _baseParams(userId: userId, controllerId: controllerId, subuserId: 0),
      );
      final SettingsMenuModel menuListToJson = SettingsMenuModel.fromEntity(menu);
      final Map<String, dynamic> template = menuListToJson.toJson();

      final Map<String, dynamic> body = {
        "menuSettingId": 502,
        "sendData": jsonEncode(template),
        "receivedData": "",
        "sentSms":"",
      };

      final response = await apiClient.post(endPoint, body: body);

      return handleApiResponse(response, parser: (dynamic data) => data, returnMessageOnNoData: true)
          .fold(
            (failure) => throw ServerException(message: failure.message),
            (message) => message,
      );
    } catch (e, s) {
      log('sendPumpSettings error :: $e');
      log('sendPumpSettings stacktrace :: $s');
      rethrow;
    }
  }
}