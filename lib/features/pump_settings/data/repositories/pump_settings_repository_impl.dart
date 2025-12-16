import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/notifications_entity.dart';
import '../../data/datasources/pump_settings_datasources.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/settings_menu_entity.dart';
import '../../domain/repositories/pump_settings_repository.dart';

class PumpSettingsRepositoryImpl implements PumpSettingsRepository {
  final PumpSettingsDataSources pumpSettingsDataSources;
  PumpSettingsRepositoryImpl({required this.pumpSettingsDataSources});

  @override
  Future<Either<Failure, List<SettingsMenuEntity>>> getSettingsMenuList(int userId, int subUserId, int controllerId) async{
    try {
      final menuList = await pumpSettingsDataSources.getSettingsMenuList(userId, subUserId, controllerId);
      return Right(menuList);
    } catch (e) {
      return Left(ServerFailure('Setting Menu Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getPumpSettings(int userId, int subUserId, int controllerId, int menuId) async{
    try {
      final menuItems = await pumpSettingsDataSources.getPumpSettings(userId, subUserId, controllerId, menuId);
      return Right(menuItems);
    } catch (e, s) {
      return Left(ServerFailure('Pump settings Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationsEntity>>> getNotifications(int userId, int subUserId, int controllerId) async{
    try {
      final notifications = await pumpSettingsDataSources.getNotifications(userId, subUserId, controllerId);
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('Notifications Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> subscribeNotifications(int userId, int subUserId, int controllerId, Map<String, dynamic> body) async{
    try {
      final notifications = await pumpSettingsDataSources.subscribeNotifications(userId, subUserId, controllerId, body);
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('Notifications Fetching Failure: $e'));
    }
  }
}