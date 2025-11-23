import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../app/controllers/agenda_controller.dart';
import '../models/consulta.dart';

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
      body: Obx(() {
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
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
    );
  }

  Widget _buildConsultaCard(Consulta consulta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horário
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text(
                  consulta.horarioFormatado,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                _buildStatusChip(consulta.status ?? ''),
              ],
            ),
            const SizedBox(height: 12),

            // Paciente
            if (consulta.nomePaciente != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consulta.nomePaciente!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Tipo
            if (consulta.tipo != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    consulta.tipo!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],

            // Observação
            if (consulta.observacao != null &&
                consulta.observacao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consulta.observacao!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toUpperCase()) {
      case 'CONFIRMADA':
        backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
        textColor = const Color(0xFF10B981);
        label = 'Confirmada';
        break;
      case 'PENDENTE':
        backgroundColor = const Color(0xFFF59E0B).withOpacity(0.1);
        textColor = const Color(0xFFF59E0B);
        label = 'Pendente';
        break;
      case 'CANCELADA':
        backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
        textColor = const Color(0xFFEF4444);
        label = 'Cancelada';
        break;
      case 'CONCLUIDA':
        backgroundColor = const Color(0xFF6366F1).withOpacity(0.1);
        textColor = const Color(0xFF6366F1);
        label = 'Concluída';
        break;
      default:
        backgroundColor = const Color(0xFF64748B).withOpacity(0.1);
        textColor = const Color(0xFF64748B);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
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
}
