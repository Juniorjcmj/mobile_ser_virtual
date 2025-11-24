import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/consulta_service.dart';
import '../../models/consulta.dart';

class AgendaController extends GetxController {
  final ConsultaService _consultaService = Get.find<ConsultaService>();

  // Estado reativo
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final RxList<Consulta> consultasDoMes = <Consulta>[].obs;
  final RxList<Consulta> consultasDoDia = <Consulta>[].obs;
  final RxBool isLoading = false.obs;

  // Formato do calendário (começa com semana)
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.week.obs;

  @override
  void onInit() {
    super.onInit();
    loadConsultasDoMes(DateTime.now());
  }

  /// Carregar consultas do mês
  Future<void> loadConsultasDoMes(DateTime mes) async {
    try {
      isLoading.value = true;

      final consultas = await _consultaService.getConsultasDoMes(mes);
      consultasDoMes.value = consultas;
      print('📅 Consultas carregadas para o mês: ${consultas.length}');

      // Atualizar consultas do dia selecionado
      _updateConsultasDoDia();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar consultas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Quando um dia é selecionado
  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    _updateConsultasDoDia();
  }

  /// Quando o mês é alterado
  void onPageChanged(DateTime focusedMonth) {
    focusedDay.value = focusedMonth;
    loadConsultasDoMes(focusedMonth);
  }

  /// Quando o formato do calendário é alterado
  void onFormatChanged(CalendarFormat format) {
    calendarFormat.value = format;
  }

  /// Atualizar lista de consultas do dia selecionado
  void _updateConsultasDoDia() {
    consultasDoDia.value = consultasDoMes
        .where((consulta) => consulta.isOnDay(selectedDay.value))
        .toList();
    print(
      '📅 Consultas para o dia ${selectedDay.value}: ${consultasDoDia.length}',
    );

    // Ordenar por horário
    consultasDoDia.sort((a, b) {
      if (a.start == null) return 1;
      if (b.start == null) return -1;
      return a.start!.compareTo(b.start!);
    });
  }

  /// Obter eventos para um dia (para marcadores no calendário)
  List<Consulta> getEventosParaDia(DateTime dia) {
    return consultasDoMes.where((consulta) => consulta.isOnDay(dia)).toList();
  }

  /// Refresh (pull-to-refresh)
  Future<void> refreshConsultas() async {
    await loadConsultasDoMes(focusedDay.value);
  }

  /// Verificar se um dia tem consultas
  bool diaTemConsultas(DateTime dia) {
    return consultasDoMes.any((consulta) => consulta.isOnDay(dia));
  }

  /// Cancelar uma consulta
  Future<void> cancelarConsulta(Consulta consulta) async {
    try {
      if (consulta.id == null) return;

      isLoading.value = true;
      await _consultaService.cancelarConsulta(consulta.id!);

      // Remover da lista local para atualizar UI instantaneamente
      consultasDoMes.removeWhere((c) => c.id == consulta.id);
      _updateConsultasDoDia();

      Get.back(); // Fechar modal se estiver aberto

      Get.snackbar(
        'Sucesso',
        'Consulta cancelada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao cancelar consulta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualizar uma consulta
  Future<void> atualizarConsulta(Consulta consulta) async {
    try {
      isLoading.value = true;
      final updatedConsulta = await _consultaService.atualizarConsulta(
        consulta,
      );

      // Atualizar na lista local
      final index = consultasDoMes.indexWhere((c) => c.id == consulta.id);
      if (index != -1) {
        consultasDoMes[index] = updatedConsulta;
      }
      _updateConsultasDoDia();

      Get.back(); // Fechar modal

      Get.snackbar(
        'Sucesso',
        'Consulta atualizada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao atualizar consulta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
