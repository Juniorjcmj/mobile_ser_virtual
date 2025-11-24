import 'dart:convert';
import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PatientService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();

  /// Busca pacientes com paginação
  /// [page] - número da página (começa em 0)
  /// [limit] - quantidade de itens por página
  /// [searchName] - nome para buscar (vazio retorna todos)
  Future<List<Patient>> getPatients({
    int page = 0,
    int limit = 20,
    String searchName = '',
  }) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      // Endpoint de autocomplete requer parâmetro 'nome' na query
      final url = '${ApiConfig.patientsEndpoint}?nome=$searchName';

      final response = await _apiService.get(url, token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allPatients = data.map((json) => Patient.fromJson(json)).toList();

        // Simular paginação no cliente
        final startIndex = page * limit;
        final endIndex = (startIndex + limit).clamp(0, allPatients.length);

        if (startIndex >= allPatients.length) {
          return [];
        }

        return allPatients.sublist(startIndex, endIndex);
      } else {
        throw Exception('Erro ao buscar pacientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getPatients: $e');
      rethrow;
    }
  }

  /// Busca um paciente específico por ID
  Future<Patient?> getPatientById(int id) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await _apiService.get(
        ApiConfig.patientByIdEndpoint(id),
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Patient.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar paciente: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getPatientById: $e');
      rethrow;
    }
  }
}
