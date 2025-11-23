import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_models.dart';
import '../models/user.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  Future<LoginResponse> login(String email, String senha) async {
    try {
      final loginRequest = LoginRequest(email: email, senha: senha);
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        loginRequest.toJson(),
      );
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Validar se a resposta contém os dados necessários
        if (data == null) {
          throw Exception('Resposta da API está vazia');
        }
        
        if (!data.containsKey('token')) {
          throw Exception('Token não encontrado na resposta');
        }
        
        if (!data.containsKey('user')) {
          throw Exception('Dados do usuário não encontrados na resposta');
        }
        
        final loginResponse = LoginResponse.fromJson(data);
        
        // Salvar token e dados do usuário
        await saveToken(loginResponse.token);
        await saveUser(loginResponse.user);
        
        return loginResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Email ou senha incorretos');
      } else if (response.statusCode == 404) {
        throw Exception('Usuário não encontrado');
      } else if (response.statusCode == 500) {
        throw Exception('Erro no servidor. Tente novamente mais tarde');
      } else {
        // Tentar extrair mensagem de erro da resposta
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Erro desconhecido';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Falha no login (${response.statusCode})');
        }
      }
    } on Exception catch (e) {
      // Re-lançar exceções já tratadas
      rethrow;
    } catch (e) {
      // Tratar erros de rede e outros erros não esperados
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException')) {
        throw Exception('Erro de conexão. Verifique sua internet');
      }
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  // Salvar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Obter token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Salvar dados do usuário
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.write(key: _userKey, value: jsonEncode(userData));
  }

  // Obter dados do usuário
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Verificar se está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
