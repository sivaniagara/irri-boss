import '../error/exceptions.dart';

Future<Map<String, dynamic>> safeApiResponse(dynamic rawResponse) async {
  if (rawResponse is! Map<String, dynamic>) {
    throw UnexpectedException('Invalid API response format: ${rawResponse.runtimeType}');
  }
  final code = rawResponse['code'] as int?;
  final message = rawResponse['message'] as String? ?? 'Unknown API error';
  if (code == 200) {
    return rawResponse;
  } else {
    throw ServerException(message: message, statusCode: code);
  }
}

Future<Map<String, dynamic>> safeApiCall(Future<dynamic> Function() apiCall) async {
  try {
    final response = await apiCall();
    return await safeApiResponse(response);
  } catch (e) {
    rethrow;
  }
}