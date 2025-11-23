import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // GET request
  Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = token != null 
        ? ApiConfig.authHeaders(token)
        : ApiConfig.defaultHeaders;

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(ApiConfig.timeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, 
    Map<String, dynamic> body, 
    {String? token}
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = token != null 
        ? ApiConfig.authHeaders(token)
        : ApiConfig.defaultHeaders;

    try {
      print('🌐 POST Request to: $url');
      print('📦 Request body: ${jsonEncode(body)}');
      
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      
      print('✅ Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Error in POST request: $e');
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, 
    Map<String, dynamic> body, 
    {String? token}
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = token != null 
        ? ApiConfig.authHeaders(token)
        : ApiConfig.defaultHeaders;

    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = token != null 
        ? ApiConfig.authHeaders(token)
        : ApiConfig.defaultHeaders;

    try {
      final response = await http
          .delete(url, headers: headers)
          .timeout(ApiConfig.timeout);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
