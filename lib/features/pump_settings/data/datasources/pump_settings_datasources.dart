import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';

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
          .replaceAll(':referenceId', '91');
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
      print("response :: $response");

      return handleApiResponse<MenuItemEntity>(
        response,
        parser: (dynamic data) {
          Map<String, dynamic> jsonMap;

          if (data is List) {
            if (data.isEmpty) {
              throw ServerException(message: "No menu item found");
            }
            jsonMap = data.first as Map<String, dynamic>;
          } else if (data is Map<String, dynamic>) {
            jsonMap = data;
          } else {
            throw ServerException(message: "Invalid data format");
          }

          final staticJson = [
            {
              "TID": 4501,
              "NAME": "On Delay Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "ONDELAY",
                  "TT": "On Delay Timer",
                  "HF": "1"
                }
              ]
            },
            {
              "TID": 4502,
              "NAME": "Starting Capacitor Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "SCRDELAY",
                  "TT": "Starting Capacitor Delay",
                  "HF": "1"
                },
                {
                  "SN": 2,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "SCRDELAY",
                  "TT": "Starting Capacitor Timer",
                  "HF": "1"
                }
              ]
            },
            {
              "TID": 4503,
              "NAME": "Star To Delta Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "SDDELAY",
                  "TT": "Star to Delta OFF Delay",
                  "HF": "1"
                }
              ]
            },
            {
              "TID": 4504,
              "NAME": "Starte Trip Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "SFB",
                  "TT": "Starter Trip",
                  "HF": "1"
                },
                {
                  "SN": 2,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "SFBDELAY",
                  "TT": "Starter Trip Timer",
                  "HF": "1"
                }
              ]
            }
          ];
          return MenuItemModel.fromJson(jsonMap, staticJson);
        },
      ).fold(
            (failure) => throw ServerException(message: failure.message),
            (menuItem) => menuItem,
      );
    } catch (e, s) {
      print('getPumpSettings error :: $e');
      print('getPumpSettings stacktrace :: $s');
      rethrow;
    }
  }
}