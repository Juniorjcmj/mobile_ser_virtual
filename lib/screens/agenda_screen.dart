import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../app/controllers/agenda_controller.dart';
import '../models/consulta.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../screens/patient_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgendaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.consultasDoMes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshConsultas(),
            child: Column(
              children: [
                // Calendário
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: controller.focusedDay.value,
                    selectedDayPredicate: (day) {
                      return isSameDay(controller.selectedDay.value, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      controller.onDaySelected(selectedDay, focusedDay);
                    },
                    onPageChanged: (focusedDay) {
                      controller.onPageChanged(focusedDay);
                    },
                    calendarFormat: controller.calendarFormat.value,
                    onFormatChanged: (format) {
                      controller.onFormatChanged(format);
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Mês',
                      CalendarFormat.week: 'Semana',
                    },
                    locale: 'pt_BR',
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    daysOfWeekHeight: 40,
                    rowHeight: 48,
                    eventLoader: (day) {
                      return controller.getEventosParaDia(day);
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Lista de consultas do dia
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Consultas do dia ${DateFormat('dd/MM/yyyy', 'pt_BR').format(controller.selectedDay.value)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: controller.consultasDoDia.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    32,
                                  ),
                                  itemCount: controller.consultasDoDia.length,
                                  itemBuilder: (context, index) {
                                    final consulta =
                                        controller.consultasDoDia[index];
                                    return _buildConsultaCard(consulta);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConsultaCard(Consulta consulta) {
    return GestureDetector(
      onTap: () => _showConsultaDetails(consulta),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Horário (Esquerda)
            SizedBox(
              width: 60,
              child: Text(
                consulta.horarioFormatado.split(
                  ' - ',
                )[0], // Apenas hora de início
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            // 2. Detalhes (Centro)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do Paciente
                  Text(
                    consulta.nomePaciente ?? 'Sem nome',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Nome do Dentista (Logo abaixo do paciente, sem padding extra)
                  if (consulta.nomeDentista != null &&
                      consulta.nomeDentista!.isNotEmpty)
                    Text(
                      consulta.nomeDentista!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  // Tipo de Procedimento com Dot Colorido
                  if (consulta.tipo != null)
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getTipoColor(consulta.tipo!),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          consulta.tipo!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    final tipoLower = tipo.toLowerCase();
    if (tipoLower.contains('procedimento')) return Colors.amber;
    if (tipoLower.contains('primeira')) return Colors.lightBlue;
    if (tipoLower.contains('retorno')) return Colors.purpleAccent;
    if (tipoLower.contains('pós') || tipoLower.contains('pos')) {
      return Colors.pinkAccent;
    }
    return Colors.grey;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma consulta agendada',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há consultas para este dia',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showConsultaDetails(Consulta consulta) async {
    final patientService = PatientService();
    Patient? patient;

    // Buscar dados do paciente se tivermos o ID
    if (consulta.pacienteId != null && consulta.pacienteId!.isNotEmpty) {
      try {
        final pacienteIdInt = int.tryParse(consulta.pacienteId!);
        if (pacienteIdInt != null) {
          patient = await patientService.getPatientById(pacienteIdInt);
        }
      } catch (e) {
        print('Erro ao buscar dados do paciente: $e');
        // Continuar mesmo se houver erro
      }
    }

    // Usar dados do paciente se disponíveis, senão usar dados da consulta
    final convenio =
        patient?.convenio ?? consulta.formaPagamento ?? 'Particular';
    final carteirinha = patient?.carteirinha ?? consulta.numeroGuiaPlano;
    final whatsappNumber = patient?.whatsapp ?? patient?.celular;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalhes da Consulta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Horário',
                      value: consulta.horarioFormatado,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 16),
                    // Nome do paciente clicável
                    GestureDetector(
                      onTap: () {
                        if (patient != null) {
                          Get.to(() => PatientDetailScreen(patient: patient!));
                        } else {
                          Get.snackbar(
                            'Aviso',
                            'Dados do paciente não disponíveis',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Paciente',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        consulta.nomePaciente ??
                                            'Não informado',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (consulta.nomeDentista != null &&
                        consulta.nomeDentista!.isNotEmpty)
                      Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.medical_services,
                            label: 'Profissional',
                            value: consulta.nomeDentista!,
                            color: const Color(0xFF8B5CF6),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (consulta.tipo != null)
                      Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.category,
                            label: 'Tipo',
                            value: consulta.tipo!,
                            color: _getTipoColor(consulta.tipo!),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    // Plano e Carteirinha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Convênio',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                convenio,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (carteirinha != null && carteirinha.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Cart. $carteirinha',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                32 + MediaQuery.of(Get.context!).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final controller = Get.find<AgendaController>();
                        controller.confirmarAusencia(consulta);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.person_off),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showEditDialog(consulta),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Cancelar Consulta',
                          middleText:
                              'Tem certeza que deseja cancelar esta consulta?',
                          textConfirm: 'Sim',
                          textCancel: 'Não',
                          confirmTextColor: Colors.white,
                          buttonColor: const Color(0xFFEF4444),
                          cancelTextColor: const Color(0xFF64748B),
                          onConfirm: () {
                            Get.back(); // Fechar diálogo
                            final controller = Get.find<AgendaController>();
                            controller.cancelarConsulta(consulta);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.cancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _launchWhatsApp(whatsappNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.chat),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _showEditDialog(Consulta consulta) {
    final obsController = TextEditingController(text: consulta.observacao);
    String? selectedStatus = consulta.status?.toUpperCase();

    // Fechar modal de detalhes
    Get.back();

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Consulta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'AGENDADO',
                        child: Text('Agendado'),
                      ),
                      const DropdownMenuItem(
                        value: 'CONFIRMADA',
                        child: Text('Confirmada'),
                      ),
                      const DropdownMenuItem(
                        value: 'PENDENTE',
                        child: Text('Pendente'),
                      ),
                      const DropdownMenuItem(
                        value: 'CANCELADA',
                        child: Text('Cancelada'),
                      ),
                      const DropdownMenuItem(
                        value: 'CONCLUIDA',
                        child: Text('Concluída'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Observação TextField
                  TextField(
                    controller: obsController,
                    decoration: const InputDecoration(
                      labelText: 'Observação',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final updatedConsulta = consulta.copyWith(
                            status: selectedStatus,
                            observacao: obsController.text,
                          );
                          Get.find<AgendaController>().atualizarConsulta(
                            updatedConsulta,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar(
        'Aviso',
        'Número de WhatsApp não disponível',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Remover caracteres não numéricos
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Erro',
          'Não foi possível abrir o WhatsApp',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao abrir WhatsApp: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
