
class AppConstants {
  static bool isPumpLive(int modelId) => {11, 13, 4, 6, 12, 30, 38}.contains(modelId);
  static bool isDoublePumpLive(int modelId) => modelId == 27;
  static bool isIrrigationLive(int modelId) => {1, 5}.contains(modelId);
}
