import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Estado reativo
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }

  // Verificar autenticação ao iniciar
  Future<void> checkAuthentication() async {
    try {
      final authenticated = await _authService.isAuthenticated();
      isAuthenticated.value = authenticated;

      if (authenticated) {
        final user = await _authService.getUser();
        currentUser.value = user;
      }
    } catch (e) {
      print('Erro ao verificar autenticação: $e');
      isAuthenticated.value = false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authService.login(email, password);

      // Atualizar estado
      isAuthenticated.value = true;
      currentUser.value = User.fromJson(response.user);

      // Aguardar próximo frame para garantir que o overlay está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Login Realizado',
          'Bem-vindo, ${currentUser.value?.nome ?? 'Usuário'}!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      });

      return true;
    } catch (e) {
      // Extrair mensagem de erro
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Determinar tipo de erro e customizar snackbar
      IconData icon = Icons.error_outline;
      Color backgroundColor = const Color(0xFFEF4444);
      String title = 'Erro no Login';

      if (errorMessage.contains('incorretos') ||
          errorMessage.contains('incorreto')) {
        icon = Icons.lock_outline;
        title = 'Credenciais Inválidas';
        errorMessage =
            'Email ou senha incorretos. Verifique seus dados e tente novamente.';
      } else if (errorMessage.contains('não encontrado')) {
        icon = Icons.person_2_outlined;
        title = 'Usuário Não Encontrado';
        errorMessage = 'Não encontramos uma conta com este email.';
      } else if (errorMessage.contains('conexão') ||
          errorMessage.contains('internet')) {
        icon = Icons.wifi_off;
        backgroundColor = const Color(0xFFF59E0B);
        title = 'Sem Conexão';
        errorMessage =
            'Verifique sua conexão com a internet e tente novamente.';
      } else if (errorMessage.contains('servidor')) {
        icon = Icons.cloud_off;
        backgroundColor = const Color(0xFFF59E0B);
        title = 'Erro no Servidor';
      }

      // Aguardar próximo frame para garantir que o overlay está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          title,
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          icon: Icon(icon, color: Colors.white, size: 28),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          forwardAnimationCurve: Curves.easeOutBack,
        );
      });

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Deseja realmente sair?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _authService.logout();
        isAuthenticated.value = false;
        currentUser.value = null;

        Get.offAllNamed(Routes.LOGIN);

        Get.snackbar(
          'Logout',
          'Você saiu da sua conta',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao fazer logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  // Atualizar dados do usuário
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getUser();
      currentUser.value = user;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
    }
  }
}
