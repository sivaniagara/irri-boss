import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

class WeatherService {
  final http.Client client;

  WeatherService({required this.client});

  Future<Map<String, dynamic>> getCurrentWeather(String? latLong) async {
    if (latLong == null || latLong.isEmpty) {
      return {"temperature_2m": "NA"};
    }

    try {
      final parts = latLong.split(',');
      if (parts.length != 2) {
        return {"temperature_2m": "NA"};
      }

      final latitude = parts[0].trim();
      final longitude = parts[1].trim();

      if (double.tryParse(latitude) == null || double.tryParse(longitude) == null) {
        return {"temperature_2m": "NA"};
      }

      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m');

      kdebugmode("🌦️ Fetching weather from: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temperature = data['current']?['temperature_2m'];
        if (temperature != null) {
          return {"temperature_2m": temperature};
        }
      }
      
      return {"temperature_2m": "NA"};
    } catch (e) {
      kdebugmode("❌ Weather fetch error: $e");
      return {"temperature_2m": "NA"};
    }
  }
}
