import 'dart:convert';
import 'package:get/get.dart';
import '../config/api_config.dart';
import '../models/doctor.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DoctorService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = Get.find<AuthService>();

  Future<List<Doctor>> getDoctors() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      final response = await _apiService.get(
        ApiConfig.doctorsEndpoint,
        token: token,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception(
          'Falha ao carregar profissionais: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao buscar profissionais: $e');
    }
  }

  Future<Doctor> getDoctorById(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      final response = await _apiService.get(
        '${ApiConfig.doctorsEndpoint}/$id',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Doctor.fromJson(data);
      } else {
        throw Exception(
          'Falha ao carregar detalhes do profissional: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do profissional: $e');
    }
  }
}
