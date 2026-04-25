import 'package:get/get.dart';
import 'app_routes.dart';

// Import dari lokasi baru (Modules)
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/map_detail/views/map_detail_view.dart';
import '../modules/rekap_kehadiran/views/rekap_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainNavView(), // Home mengarah ke navigasi utama
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.MAP_DETAIL,
      page: () => MapDetailView(
        mataKuliahData: Get.arguments['mataKuliahData'],
        nimMahasiswa: Get.arguments['nimMahasiswa'],
      ),
    ),
    GetPage(
      name: Routes.REKAP,
      page: () => RekapView(),
    ),
  ];
}
