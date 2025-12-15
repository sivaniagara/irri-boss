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
      // print("response :: $response");

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
              "TID": 4491,
              "NAME": "Dry Run Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "DRYRUN",
                  "TT": "Dry Run Scan",
                  "HF": "1"
                },
                {
                  "SN": 2,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "DRSCAN",
                  "TT": "Dry Run Scan Timer",
                  "HF": "1"
                },
                {
                  "SN": 3,
                  "WT": 1,
                  "VAL": "0",
                  "SF": "DRAMPS2",
                  "TT": "Dry Run Amps 2PH",
                  "HF": "0"
                },
                {
                  "SN": 4,
                  "WT": 1,
                  "VAL": "0",
                  "SF": "DRAMPS3",
                  "TT": "Dry Run Amps 3PH",
                  "HF": "1"
                },
                {
                  "SN": 5,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "DRRESTART",
                  "TT": "Dry Run Restart",
                  "HF": "0"
                },
                {
                  "SN": 6,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "DRRESTART",
                  "TT": "Dry Run Restart Timer",
                  "HF": "0"
                },
                {
                  "SN": 7,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "DRYRUN",
                  "TT": "Dry Run Occurance",
                  "HF": "0"
                },
                {
                  "SN": 8,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "DROCCURTIM",
                  "TT": "Dry Run Occurance Timer",
                  "HF": "0"
                },
                {
                  "SN": 9,
                  "WT": 1,
                  "VAL": "0",
                  "SF": "DROCCURNBR",
                  "TT": "Dry Run Occurance Count",
                  "HF": "0"
                }
              ]
            },
            {
              "TID": 4492,
              "NAME": "Overload Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "OL",
                  "TT": "Overload Scan",
                  "HF": "1"
                },
                {
                  "SN": 2,
                  "WT": 3,
                  "VAL": "00:00:00",
                  "SF": "OLSCAN",
                  "TT": "Overload Scan Timer",
                  "HF": "1"
                },
                {
                  "SN": 3,
                  "WT": 1,
                  "VAL": "0",
                  "SF": "OLAMPS2",
                  "TT": "Overload Amps 2PH",
                  "HF": "0"
                },
                {
                  "SN": 4,
                  "WT": 1,
                  "VAL": "0",
                  "SF": "OLAMPS3",
                  "TT": "Overload Amps 3PH",
                  "HF": "1"
                }
              ]
            },
            {
              "TID": 4493,
              "NAME": "Power on reset Settings",
              "SETS": [
                {
                  "SN": 1,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "DRRESTART",
                  "TT": "Dry Run Power ON Reset",
                  "HF": "1"
                },
                {
                  "SN": 2,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "OLRST",
                  "TT": "Overload Power ON Reset",
                  "HF": "1"
                },
                {
                  "SN": 3,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "MOBILERST",
                  "TT": "Auto Restart",
                  "HF": "0"
                },
                {
                  "SN": 4,
                  "WT": 2,
                  "VAL": "OF",
                  "SF": "AUTORST2",
                  "TT": "Auto Restart 2PH",
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
      log('getPumpSettings error :: $e');
      log('getPumpSettings stacktrace :: $s');
      rethrow;
    }
  }
}