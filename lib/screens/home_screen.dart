import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/home_controller.dart';
import '../app/controllers/auth_controller.dart';
import '../app/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sec Virtual'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => homeController.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com gradiente
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bem-vindo,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          homeController.currentUser.value?.nome ?? 'Usuário',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              homeController.currentUser.value?.email ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Cards de funcionalidades
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Funcionalidades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid de cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildFeatureCard(
                            icon: Icons.calendar_today,
                            title: 'Agendamentos',
                            color: const Color(0xFF6366F1),
                            onTap: () => Get.toNamed(Routes.AGENDA),
                          ),
                          _buildFeatureCard(
                            icon: Icons.person,
                            title: 'Perfil',
                            color: const Color(0xFF10B981),
                            onTap: () => Get.toNamed(Routes.PROFILE),
                          ),
                          _buildFeatureCard(
                            icon: Icons.medical_services,
                            title: 'Consultas',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Get.snackbar(
                                'Em Desenvolvimento',
                                'Funcionalidade em desenvolvimento',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                          _buildFeatureCard(
                            icon: Icons.settings,
                            title: 'Configurações',
                            color: const Color(0xFF8B5CF6),
                            onTap: () => Get.toNamed(Routes.SETTINGS),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Informações do usuário
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informações da Conta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.badge,
                                'ID',
                                homeController.currentUser.value?.id
                                        ?.toString() ??
                                    'N/A',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.phone,
                                'Telefone',
                                homeController.currentUser.value?.telefone ??
                                    'Não informado',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.credit_card,
                                'CPF',
                                homeController.currentUser.value?.cpf ??
                                    'Não informado',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.admin_panel_settings,
                                'Função',
                                homeController.currentUser.value?.role ??
                                    'Usuário',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
