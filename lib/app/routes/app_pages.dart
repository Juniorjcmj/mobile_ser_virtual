import 'package:get/get.dart';
import '../../screens/login_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/agenda_screen.dart';
import '../../main.dart';
import '../../services/consulta_service.dart';
import '../controllers/agenda_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.AGENDA,
      page: () => const AgendaScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ConsultaService>(() => ConsultaService());
        Get.lazyPut<AgendaController>(() => AgendaController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}
