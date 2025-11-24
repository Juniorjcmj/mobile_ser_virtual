import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/controllers/home_controller.dart';
import '../app/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Já está na home
        break;
      case 1:
        Get.toNamed(Routes.AGENDA);
        break;
      case 2:
        Get.toNamed(Routes.PATIENTS);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
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
                  // Header com logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Clinsaúde',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: const Color(0xFF64748B),
                          onPressed: () {
                            // TODO: Implementar notificações
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Título "Choose your area"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Escolha sua área',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de opções
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildOptionCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Agenda',
                          color: const Color(0xFF6366F1),
                          isLarge: true,
                          onTap: () => Get.toNamed(Routes.AGENDA),
                        ),
                        _buildOptionCard(
                          icon: Icons.people_outline,
                          label: 'Pacientes',
                          color: const Color(0xFF6366F1),
                          onTap: () => Get.toNamed(Routes.PATIENTS),
                        ),
                        _buildOptionCard(
                          icon: Icons.person_outline,
                          label: 'Profissionais',
                          color: const Color(0xFF6366F1),
                          onTap: () => Get.toNamed(Routes.DOCTORS),
                        ),
                        _buildOptionCard(
                          icon: Icons.settings_outlined,
                          label: 'Configurações',
                          color: const Color(0xFF6366F1),
                          onTap: () => Get.toNamed(Routes.SETTINGS),
                        ),
                        _buildOptionCard(
                          icon: Icons.person,
                          label: 'Perfil',
                          color: const Color(0xFF6366F1),
                          onTap: () => Get.toNamed(Routes.PROFILE),
                        ),
                        _buildOptionCard(
                          icon: Icons.help_outline,
                          label: 'Ajuda',
                          color: const Color(0xFF6366F1),
                          onTap: () {
                            // TODO: Implementar ajuda
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: _selectedIndex,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Agenda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Pacientes',
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isLarge
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isLarge ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isLarge
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: isLarge
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLarge
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: isLarge ? 40 : 32,
                color: isLarge ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLarge ? Colors.white : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
