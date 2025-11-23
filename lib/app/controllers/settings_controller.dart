import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();

  // Preferências reativas
  final RxBool notificationsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxBool biometricEnabled = false.obs;

  // Keys para storage
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _biometricKey = 'biometric_enabled';

  @override
  void onInit() {
    super.onInit();
    loadPreferences();

    // Workers para salvar automaticamente quando mudar
    ever(notificationsEnabled, (_) => savePreferences());
    ever(darkModeEnabled, (_) => savePreferences());
    ever(biometricEnabled, (_) => savePreferences());
  }

  // Carregar preferências
  void loadPreferences() {
    notificationsEnabled.value = _storage.read(_notificationsKey) ?? true;
    darkModeEnabled.value = _storage.read(_darkModeKey) ?? false;
    biometricEnabled.value = _storage.read(_biometricKey) ?? false;
  }

  // Salvar preferências
  void savePreferences() {
    _storage.write(_notificationsKey, notificationsEnabled.value);
    _storage.write(_darkModeKey, darkModeEnabled.value);
    _storage.write(_biometricKey, biometricEnabled.value);
  }

  // Toggle notificações
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  // Toggle dark mode
  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;

    // Mudar tema do app
    if (value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }

    Get.snackbar(
      'Tema',
      value ? 'Modo escuro ativado' : 'Modo claro ativado',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Toggle biometria
  void toggleBiometric(bool value) {
    biometricEnabled.value = value;
    Get.snackbar(
      'Em Desenvolvimento',
      'Autenticação biométrica em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
