import 'dart:developer';

import '../../domain/entities/menu_item_entity.dart';
import '../models/menu_item_model.dart';
import '../models/settings_menu_model.dart';
import '../../utils/pump_settings_urls.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../domain/entities/settings_menu_entity.dart';

import '../../../../core/services/api_client.dart';

abstract class PumpSettingsDataSources {
  Future<List<SettingsMenuEntity>> getSettingsMenuList(int userId, int subUserId, int controllerId);
  Future<MenuItemEntity> getPumpSettings(int userId, int subUserId, int controllerId, int menuId);
}

class PumpSettingsDataSourcesImpl implements PumpSettingsDataSources {
  final ApiClient apiClient;
  PumpSettingsDataSourcesImpl({required this.apiClient});

  @override
  Future<List<SettingsMenuEntity>> getSettingsMenuList(int userId, int subUserId, int controllerId) async{
    try {
      final endpoint = PumpSettingsUrls.getSettingsMenu
          .replaceAll(':userId', userId.toString())
          .replaceAll(':subUserId', '0')
          .replaceAll(':controllerId', controllerId.toString())
          .replaceAll(':referenceId', '600');
      final response = await apiClient.get(endpoint);
      return handleListResponse<SettingsMenuModel>(
        response,
        fromJson: (json) => SettingsMenuModel.fromJson(json),
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (groups) => groups.cast<SettingsMenuEntity>(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MenuItemEntity> getPumpSettings(
      int userId, int subUserId, int controllerId, int menuId) async {
    try {
      final endpoint = PumpSettingsUrls.getFinalMenu
          .replaceAll(':userId', userId.toString())
          .replaceAll(':subUserId', '0')
          .replaceAll(':controllerId', controllerId.toString())
          .replaceAll(':referenceId', '91')
          .replaceAll(':menuId', menuId.toString());

      final response = await apiClient.get(endpoint);
      // print("response :: $response");

      return handleApiResponse<MenuItemEntity>(
        response,
        parser: (dynamic data) {
          return MenuItemModel.fromJson(data[0]);
        },
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (menuItem) => menuItem,
      );
    } catch (e, s) {
      log('getPumpSettings error :: $e');
      log('getPumpSettings stacktrace :: $s');
      rethrow;
    }
  }
}