import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Injetar serviços como singletons
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
  }
}
