import 'package:shared_preferences/shared_preferences.dart';

class SelectedControllerPersistence {
  static const _keyDeviceId = 'last_selected_device_id';
  static const _keyGroupId = 'last_selected_group_id';

  static final SelectedControllerPersistence _instance = SelectedControllerPersistence._();
  factory SelectedControllerPersistence() => _instance;
  SelectedControllerPersistence._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save
  Future<void> save(String deviceId, int groupId) async {
    await _prefs.setString(_keyDeviceId, deviceId);
    await _prefs.setInt(_keyGroupId, groupId);
  }

  // Load
  String? get deviceId => _prefs.getString(_keyDeviceId);
  int? get groupId => _prefs.getInt(_keyGroupId);

  // Clear (on logout)
  Future<void> clear() async {
    await _prefs.remove(_keyDeviceId);
    await _prefs.remove(_keyGroupId);
  }
}