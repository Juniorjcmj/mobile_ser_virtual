import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/doctor_detail_controller.dart';
import '../models/doctor.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Profissional'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final doctor = controller.doctor.value;
        if (doctor == null) {
          return const Center(child: Text('Profissional não encontrado'));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar and Name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFE0E7FF),
                        child: Text(
                          doctor.nome?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        doctor.nome ?? 'Nome não informado',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (doctor.cro != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Chip(
                            label: Text(
                              'CRO: ${doctor.cro}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: const Color(0xFFE0E7FF),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Especialidades
                if (doctor.especialidades != null &&
                    doctor.especialidades!.isNotEmpty) ...[
                  const Text(
                    'Especialidades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.especialidades!.map((e) {
                      return Chip(
                        label: Text(e.nome ?? ''),
                        backgroundColor: const Color(0xFFF1F5F9),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Informações de Contato
                _buildSectionTitle('Contato'),
                _buildInfoTile(Icons.email, 'Email', doctor.email),
                _buildInfoTile(Icons.phone, 'Celular', doctor.celular),
                _buildInfoTile(Icons.chat, 'WhatsApp', doctor.whatsapp),
                const SizedBox(height: 24),

                // Endereço
                _buildSectionTitle('Endereço'),
                _buildInfoTile(Icons.location_on, 'Logradouro', doctor.rua),
                _buildInfoTile(Icons.map, 'Bairro', doctor.bairro),
                _buildInfoTile(
                  Icons.location_city,
                  'Cidade/UF',
                  doctor.cidade != null
                      ? '${doctor.cidade}/${doctor.uf ?? ""}'
                      : null,
                ),
                _buildInfoTile(Icons.markunread_mailbox, 'CEP', doctor.cep),

                const SizedBox(height: 24),

                // Outros
                _buildSectionTitle('Outras Informações'),
                _buildInfoTile(Icons.cake, 'Idade', doctor.idade?.toString()),
                _buildInfoTile(Icons.badge, 'CPF', doctor.cpf),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
