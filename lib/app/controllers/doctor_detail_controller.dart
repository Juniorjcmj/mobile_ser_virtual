import 'package:get/get.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';

class DoctorDetailController extends GetxController {
  final DoctorService _doctorService = Get.find<DoctorService>();

  final Rx<Doctor?> doctor = Rx<Doctor?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is int) {
      fetchDoctorDetails(Get.arguments as int);
    } else {
      errorMessage.value = 'ID do profissional não fornecido';
    }
  }

  Future<void> fetchDoctorDetails(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _doctorService.getDoctorById(id);
      doctor.value = result;
    } catch (e) {
      errorMessage.value = 'Erro ao carregar detalhes: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
