import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Estado reativo
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;

  // Controllers de texto
  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final cpfController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nomeController.dispose();
    telefoneController.dispose();
    cpfController.dispose();
    super.onClose();
  }

  // Carregar dados do usuário
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = await _authService.getUser();
      currentUser.value = user;

      // Preencher controllers
      nomeController.text = user?.nome ?? '';
      telefoneController.text = user?.telefone ?? '';
      cpfController.text = user?.cpf ?? '';
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados do perfil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle modo de edição
  void toggleEdit() {
    if (isEditing.value) {
      // Cancelar edição - restaurar valores
      nomeController.text = currentUser.value?.nome ?? '';
      telefoneController.text = currentUser.value?.telefone ?? '';
      cpfController.text = currentUser.value?.cpf ?? '';
    }
    isEditing.value = !isEditing.value;
  }

  // Salvar perfil
  Future<void> saveProfile() async {
    // TODO: Implementar chamada à API
    Get.snackbar(
      'Em Desenvolvimento',
      'Funcionalidade de edição em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    isEditing.value = false;
  }
}
