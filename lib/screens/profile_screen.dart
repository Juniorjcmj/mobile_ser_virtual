import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(
            () => !controller.isEditing.value
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => controller.toggleEdit(),
                    tooltip: 'Editar',
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => controller.toggleEdit(),
                        tooltip: 'Cancelar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => controller.saveProfile(),
                        tooltip: 'Salvar',
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                // Header com avatar
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.currentUser.value?.nome ?? 'Usuário',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.currentUser.value?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Informações do perfil
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações Pessoais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card de informações
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildProfileField(
                                icon: Icons.person_outline,
                                label: 'Nome',
                                controller: controller.nomeController,
                                enabled: controller.isEditing.value,
                              ),
                              const Divider(),
                              _buildProfileField(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value:
                                    controller.currentUser.value?.email ?? '',
                                enabled: false,
                              ),
                              const Divider(),
                              _buildProfileField(
                                icon: Icons.phone_outlined,
                                label: 'Telefone',
                                controller: controller.telefoneController,
                                enabled: controller.isEditing.value,
                              ),
                              const Divider(),
                              _buildProfileField(
                                icon: Icons.credit_card,
                                label: 'CPF',
                                controller: controller.cpfController,
                                enabled: controller.isEditing.value,
                              ),
                              const Divider(),
                              _buildProfileField(
                                icon: Icons.badge,
                                label: 'ID',
                                value:
                                    controller.currentUser.value?.id
                                        ?.toString() ??
                                    'N/A',
                                enabled: false,
                              ),
                              const Divider(),
                              _buildProfileField(
                                icon: Icons.admin_panel_settings,
                                label: 'Função',
                                value:
                                    controller.currentUser.value?.role ??
                                    'Usuário',
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Seção de segurança
                      const Text(
                        'Segurança',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF6366F1),
                              ),
                              title: const Text('Alterar Senha'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Get.snackbar(
                                  'Em Desenvolvimento',
                                  'Funcionalidade em desenvolvimento',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.security,
                                color: Color(0xFF10B981),
                              ),
                              title: const Text('Autenticação em Dois Fatores'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Get.snackbar(
                                  'Em Desenvolvimento',
                                  'Funcionalidade em desenvolvimento',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    String? value,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF6366F1)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                if (controller != null)
                  TextField(
                    controller: controller,
                    enabled: enabled,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  )
                else
                  Text(
                    value ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
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
