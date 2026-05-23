import 'package:get/get.dart';
import '../../../app_routes/app_routes.dart';
import '../../../utils/SharedPrefs.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  void _startApp() async {
    // Delay untuk memberikan waktu animasi splash screen selesai
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (SharedPrefs.getLoginStatus()) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
