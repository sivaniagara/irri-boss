import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/models/user_model.dart';
import '../error/exceptions.dart';
import 'network_info.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final AuthLocalDataSource _authLocalDataSource;
  final NetworkInfo _networkInfo;

  ApiClient({required this.baseUrl, required this.client})
      : _authLocalDataSource = GetIt.instance<AuthLocalDataSource>(),
        _networkInfo = GetIt.instance<NetworkInfo>();

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _makeRequest('GET', endpoint, headers: headers, body: null);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _makeRequest('POST', endpoint, headers: headers, body: body);
  }

  // Add similar wrappers for PUT, DELETE, etc., if needed
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return _makeRequest('PUT', endpoint, headers: headers, body: body);
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    return _makeRequest('DELETE', endpoint, headers: headers, body: null);
  }

  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      // Build merged headers (common logic)
      final user = await _authLocalDataSource.getCachedAuthData();
      final mergedHeaders = {
        'Content-Type': 'application/json',
        if (user != null) 'userId': '${user.userDetails.id}',
        if (user != null) 'Authorization': 'Bearer ${user.userDetails.deviceToken}',
        ...?headers,
      };

      print("Request Method: $method | Endpoint: $endpoint");
      // print("Request Body: $body");
      // print("Encoded Body: ${jsonEncode(body)}");

      // Make the initial request
      final requestUri = Uri.parse('$baseUrl$endpoint');
      http.Response response;
      if (method.toUpperCase() == 'GET') {
        response = await client.get(requestUri, headers: mergedHeaders).timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'POST') {
        response = await client.post(requestUri, headers: mergedHeaders, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'PUT') {
        response = await client.put(requestUri, headers: mergedHeaders, body: body != null ? jsonEncode(body) : null)
            .timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'DELETE') {
        response = await client.delete(requestUri, headers: mergedHeaders).timeout(const Duration(seconds: 15));
      } else {
        throw UnsupportedError('HTTP method $method not supported');
      }

      // Handle response with retry logic
      return _handleResponseWithRetry(response, method, endpoint, mergedHeaders, body);
    } on TimeoutException {
      throw TimeoutException("$method request to $endpoint timed out");
    } catch (e) {
      rethrow; // Re-throw other exceptions
    }
  }

  Future<dynamic> _handleResponseWithRetry(
    http.Response response,
    String method,
    String endpoint,
    Map<String, String> headers,
    dynamic body,
  ) async {
    final statusCode = response.statusCode;
    final responseBody = response.body.isNotEmpty ? response.body : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody != null ? jsonDecode(responseBody) : null;
    } else if (statusCode == 401) {
      return await _attemptTokenRefreshAndRetry(method, endpoint, headers, body);
    } else if (statusCode == 500) {
      throw ServerException(message: responseBody ?? "Internal Server Error", statusCode: 500);
    } else if (statusCode == 404) {
      throw NotFoundException(message: responseBody ?? "Resource not found", code: 404);
    } else if (statusCode >= 400 && statusCode < 500) {
      throw ValidationException(message: responseBody ?? "Invalid request", code: statusCode);
    } else {
      throw UnexpectedException("Error $statusCode: $responseBody");
    }
  }

  Future<dynamic> _attemptTokenRefreshAndRetry(
    String method,
    String endpoint,
    Map<String, String> originalHeaders,
    dynamic originalBody,
  ) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      await _authLocalDataSource.clearAuthData();
      throw UnauthorizedException(message: "Unauthorized: No valid user session");
    }

    try {
      // Force refresh Firebase token
      final newToken = await firebaseUser.getIdToken(true);

      // Update cached user with new token
      final user = await _authLocalDataSource.getCachedAuthData();
      if (user != null) {
        final updatedUser = RegisterDetailsModel.fromJson(user.toJson());
        updatedUser.userDetails.deviceToken = newToken;
        await _authLocalDataSource.cacheAuthData(updatedUser);
      } else {
        throw UnauthorizedException(message: "No cached user data found");
      }

      // Rebuild headers with new token
      final updatedHeaders = {
        ...originalHeaders,
        'Authorization': 'Bearer $newToken',
      };

      print("Token refreshed. Retrying $method request to $endpoint");

      // Retry the request
      final requestUri = Uri.parse('$baseUrl$endpoint');
      http.Response retryResponse;
      if (method.toUpperCase() == 'GET') {
        retryResponse = await client.get(requestUri, headers: updatedHeaders).timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'POST') {
        retryResponse = await client
            .post(requestUri, headers: updatedHeaders, body: originalBody != null ? jsonEncode(originalBody) : null)
            .timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'PUT') {
        retryResponse = await client
            .put(requestUri, headers: updatedHeaders, body: originalBody != null ? jsonEncode(originalBody) : null)
            .timeout(const Duration(seconds: 15));
      } else if (method.toUpperCase() == 'DELETE') {
        retryResponse = await client.delete(requestUri, headers: updatedHeaders).timeout(const Duration(seconds: 15));
      } else {
        throw UnsupportedError('HTTP method $method not supported');
      }

      // Handle the retry response
      final retryStatusCode = retryResponse.statusCode;
      final retryBody = retryResponse.body.isNotEmpty ? retryResponse.body : null;

      if (retryStatusCode >= 200 && retryStatusCode < 300) {
        return retryBody != null ? jsonDecode(retryBody) : null;
      } else if (retryStatusCode == 401) {
        await _authLocalDataSource.clearAuthData();
        throw UnauthorizedException(message: retryBody ?? "Token refresh failed: Still unauthorized");
      } else if (retryStatusCode == 500) {
        throw ServerException(message: retryBody ?? "Internal Server Error after retry", statusCode: 500);
      } else {
        throw UnexpectedException("Retry failed with status $retryStatusCode: $retryBody");
      }
    } catch (e) {
      await _authLocalDataSource.clearAuthData();
      throw UnauthorizedException(message: "Token refresh failed: $e");
    }
  }
}