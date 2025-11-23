import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Estado reativo
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // Carregar dados do usuário
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = await _authService.getUser();
      currentUser.value = user;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados do usuário',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh (pull to refresh)
  Future<void> refreshData() async {
    await loadUserData();
  }
}
