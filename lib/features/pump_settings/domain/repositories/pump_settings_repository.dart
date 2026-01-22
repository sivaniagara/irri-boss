import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/notifications_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/settings_menu_entity.dart';

abstract class PumpSettingsRepository {
  Future<Either<Failure, List<MenuItemEntity>>> getSettingsMenuList(int userId, int subUserId, int controllerId);
  Future<Either<Failure, MenuItemEntity>> getPumpSettings(int userId, int subUserId, int controllerId, int menuId);
  Future<Either<Failure, List<NotificationsEntity>>> getNotifications(int userId, int subUserId, int controllerId);
  Future<Either<Failure, String>> subscribeNotifications(int userId, int subUserId, int controllerId, Map<String, dynamic> body);
  Future<Either<Failure, String>> sendPumpSettings(int userId, int subUserId, int controllerId, MenuItemEntity menuItem, String sentSms);
  Future<Either<Failure, String>> updateMenuStatus(int userId, int subUserId, int controllerId, SettingsMenuEntity menuList);
}