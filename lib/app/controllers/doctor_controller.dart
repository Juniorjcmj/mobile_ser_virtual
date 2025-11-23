import 'package:get/get.dart';
import '../../models/doctor.dart';
import '../../services/doctor_service.dart';

class DoctorController extends GetxController {
  final DoctorService _doctorService = Get.find<DoctorService>();

  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _doctorService.getDoctors();
      doctors.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Erro ao carregar profissionais: $e';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDoctors() async {
    await fetchDoctors();
  }
}
