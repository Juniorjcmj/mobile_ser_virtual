import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/settings_controller.dart';
import '../app/controllers/auth_controller.dart';
import '../app/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF10B981)],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Personalize seu aplicativo',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Seção de Preferências
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferências',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => SwitchListTile(
                          secondary: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF6366F1),
                          ),
                          title: const Text('Notificações'),
                          subtitle: const Text('Receber notificações do app'),
                          value: controller.notificationsEnabled.value,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: controller.toggleNotifications,
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          secondary: const Icon(
                            Icons.dark_mode_outlined,
                            color: Color(0xFF6366F1),
                          ),
                          title: const Text('Modo Escuro'),
                          subtitle: const Text('Ativar tema escuro'),
                          value: controller.darkModeEnabled.value,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: controller.toggleDarkMode,
                        ),
                      ),
                      const Divider(height: 1),
                      Obx(
                        () => SwitchListTile(
                          secondary: const Icon(
                            Icons.fingerprint,
                            color: Color(0xFF6366F1),
                          ),
                          title: const Text('Biometria'),
                          subtitle: const Text('Login com biometria'),
                          value: controller.biometricEnabled.value,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: controller.toggleBiometric,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Conta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF6366F1),
                        ),
                        title: const Text('Editar Perfil'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Get.toNamed(Routes.PROFILE),
                      ),
                      const Divider(height: 1),
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
                          Icons.privacy_tip_outlined,
                          color: Color(0xFF6366F1),
                        ),
                        title: const Text('Privacidade'),
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

          const SizedBox(height: 24),

          // Seção de Sobre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sobre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF6366F1),
                        ),
                        title: const Text('Sobre o App'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF10B981),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.medication_liquid,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Sec Virtual'),
                                ],
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Versão: 1.0.0'),
                                  SizedBox(height: 8),
                                  Text(
                                    'Aplicativo móvel para gerenciamento de consultas odontológicas.',
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: Color(0xFF6366F1),
                        ),
                        title: const Text('Ajuda e Suporte'),
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
                          Icons.description_outlined,
                          color: Color(0xFF6366F1),
                        ),
                        title: const Text('Termos de Uso'),
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

          const SizedBox(height: 24),

          // Botão de Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              color: const Color(0xFFFEF2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => authController.logout(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Versão do app
          Center(
            child: Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
