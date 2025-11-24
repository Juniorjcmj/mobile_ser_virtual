import 'dart:convert';
import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/anamnese.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AnamneseService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();

  /// Busca a anamnese de um paciente específico
  Future<Anamnese?> getAnamneseByPacienteId(int pacienteId) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await _apiService.get(
        ApiConfig.anamneseByPacienteIdEndpoint(pacienteId),
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Anamnese.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar anamnese: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getAnamneseByPacienteId: $e');
      rethrow;
    }
  }

  /// Salva ou atualiza a anamnese de um paciente
  Future<Anamnese> saveAnamnese(Anamnese anamnese) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await _apiService.post(
        ApiConfig.anamneseEndpoint,
        anamnese.toJson(),
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Anamnese.fromJson(data);
      } else {
        throw Exception('Erro ao salvar anamnese: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em saveAnamnese: $e');
      rethrow;
    }
  }
}
