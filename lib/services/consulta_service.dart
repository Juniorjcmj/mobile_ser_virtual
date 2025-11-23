import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consulta.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:get/get.dart';

class ConsultaService {
  final AuthService _authService = Get.find<AuthService>();

  /// Buscar consultas por período
  Future<List<Consulta>> getPorPeriodo(DateTime inicio, DateTime fim) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      // Formatar datas para ISO 8601 com timezone (igual ao Angular)
      // Formato: YYYY-MM-DDTHH:mm:ssZ com offset -03:00
      final inicioStr = inicio
          .toUtc()
          .subtract(const Duration(hours: 3))
          .toIso8601String();
      final fimStr = fim
          .toUtc()
          .subtract(const Duration(hours: 3))
          .toIso8601String();

      // Construir URL com query parameters usando o endpoint /periodo
      final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.consultasEndpoint}/periodo',
      ).replace(queryParameters: {'inicio': inicioStr, 'fim': fimStr});

      print('🔍 Buscando consultas: $url');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await http
          .get(url, headers: ApiConfig.authHeaders(token))
          .timeout(ApiConfig.timeout);

      print('📊 Status da resposta: ${response.statusCode}');
      print('📨 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Consulta.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        // Tentar extrair mensagem de erro
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Acesso negado. Você não tem permissão para acessar consultas.';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Acesso negado. Verifique suas permissões.');
        }
      } else if (response.statusCode == 404) {
        // Nenhuma consulta encontrada
        return [];
      } else {
        throw Exception('Erro ao buscar consultas: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Erro de conexão. Verifique sua internet');
      }
      rethrow;
    }
  }

  /// Buscar consultas de um dia específico
  Future<List<Consulta>> getConsultasDoDia(DateTime data) async {
    final inicio = DateTime(data.year, data.month, data.day, 0, 0, 0);
    final fim = DateTime(data.year, data.month, data.day, 23, 59, 59);
    return await getPorPeriodo(inicio, fim);
  }

  /// Buscar consultas de um mês específico
  Future<List<Consulta>> getConsultasDoMes(DateTime mes) async {
    final inicio = DateTime(mes.year, mes.month, 1, 0, 0, 0);
    final fim = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);
    return await getPorPeriodo(inicio, fim);
  }
}
