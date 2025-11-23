import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/patient_controller.dart';
import '../models/patient.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Campo de busca
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar paciente (mín. 3 caracteres)',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6366F1),
                  ),
                  suffixIcon: Obx(
                    () => controller.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.refreshPatients();
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Lista de pacientes
            Expanded(
              child: Obx(() {
                // Estado de carregamento inicial
                if (controller.isLoading.value && controller.patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Estado de erro
                if (controller.errorMessage.isNotEmpty &&
                    controller.patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refreshPatients,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Lista de pacientes com opacidade durante busca
                return Opacity(
                  opacity: controller.isSearching.value ? 0.5 : 1.0,
                  child: RefreshIndicator(
                    onRefresh: controller.refreshPatients,
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount:
                          controller.patients.length +
                          (controller.hasMoreData.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Indicador de carregamento no final
                        if (index == controller.patients.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final patient = controller.patients[index];
                        return _buildPatientCard(patient);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar com inicial ou cor
            CircleAvatar(
              radius: 30,
              backgroundColor: patient.cor != null && patient.cor!.isNotEmpty
                  ? _parseColor(patient.cor!)
                  : const Color(0xFFE0E7FF),
              child: Text(
                patient.nome?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Informações do paciente
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    patient.nome ?? 'Nome não informado',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Convênio
                  if (patient.convenio != null && patient.convenio!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.convenio!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  // Celular
                  if (patient.celular != null && patient.celular!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            patient.celular!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status ativo/inativo
                  if (patient.ativo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: patient.ativo!
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          patient.ativo! ? 'ATIVO' : 'INATIVO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: patient.ativo!
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Menu de 3 pontos
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                _handleMenuAction(value, patient);
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Color(0xFF6366F1),
                      ),
                      SizedBox(width: 12),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'whatsapp',
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_outlined,
                        size: 20,
                        color: Color(0xFF25D366),
                      ),
                      SizedBox(width: 12),
                      Text('WhatsApp'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'agendar',
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 12),
                      Text('Agendar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Trata as ações do menu
  void _handleMenuAction(String action, Patient patient) {
    switch (action) {
      case 'editar':
        Get.snackbar(
          'Editar',
          'Editar paciente: ${patient.nome}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF6366F1),
          colorText: Colors.white,
        );
        break;
      case 'whatsapp':
        // Usa whatsapp se disponível, senão usa celular
        final phoneNumber =
            (patient.whatsapp != null && patient.whatsapp!.isNotEmpty)
            ? patient.whatsapp
            : patient.celular;

        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          Get.snackbar(
            'WhatsApp',
            'Abrindo WhatsApp: $phoneNumber',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF25D366),
            colorText: Colors.white,
          );
          // TODO: Implementar abertura do WhatsApp
          // url_launcher: whatsapp://send?phone=$phoneNumber
        } else {
          Get.snackbar(
            'WhatsApp',
            'Paciente não possui telefone cadastrado',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
        break;
      case 'agendar':
        Get.snackbar(
          'Agendar',
          'Agendar consulta para: ${patient.nome}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
        );
        // TODO: Navegar para tela de agendamento
        break;
    }
  }

  /// Parse color string (hex) to Color
  Color _parseColor(String colorString) {
    try {
      // Remove # se existir
      String hexColor = colorString.replaceAll('#', '');

      // Adiciona FF (opacidade total) se não tiver alpha
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return const Color(0xFFE0E7FF); // Cor padrão em caso de erro
    }
  }
}
