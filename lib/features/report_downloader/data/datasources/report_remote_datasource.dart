import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ReportRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchReport(String url);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> fetchReport(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("API Error");
    }
    final decoded = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(decoded['data']);
  }
}
