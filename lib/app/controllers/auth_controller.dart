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
    _checkAuthentication();
  }

  // Verificar autenticação ao iniciar
  Future<void> _checkAuthentication() async {
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
  Future<bool> login(String email, String senha) async {
    try {
      isLoading.value = true;

      final response = await _authService.login(email, senha);

      // Atualizar estado
      isAuthenticated.value = true;
      currentUser.value = User.fromJson(response.user);

      Get.snackbar(
        'Sucesso',
        'Login realizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      // Extrair mensagem de erro
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      Get.snackbar(
        'Erro no Login',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );

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
