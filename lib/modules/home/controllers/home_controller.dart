import 'package:get/get.dart';
import '../../../main.dart'; // Menyesuaikan path ke main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  // Variabel umum
  var role = "mahasiswa".obs;
  var namaMhs = "".obs;
  var prodi = "".obs;

  // Khusus Mahasiswa
  var nim = "".obs;
  var fotoUrl = "".obs;

  // Khusus Dosen
  var email = "".obs;
  var fakultas = "".obs;

  var listJadwal = <dynamic>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      role.value = Get.arguments['role'] ?? 'mahasiswa';
      namaMhs.value = Get.arguments['nama'] ?? '';
      prodi.value = Get.arguments['prodi'] ?? '';

      if (role.value == 'mahasiswa') {
        nim.value = Get.arguments['nim'] ?? '';
        _generateFotoUrl();
      } else {
        email.value = Get.arguments['email'] ?? '-';
        fakultas.value = Get.arguments['fakultas'] ?? '-';
      }
    }
    _fetchJadwalDariSupabase();
  }

  void _generateFotoUrl() {
    if (nim.value.length >= 4) {
      String folder = nim.value.substring(0, 4);
      fotoUrl.value = "https://krs.umm.ac.id/Poto/$folder/${nim.value}.JPG";
    }
  }

  Future<void> _fetchJadwalDariSupabase() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('mata_kuliah')
          .select('''
            id,
            nama_mk,
            jam_mulai,
            jam_selesai,
            ruang,
            latitude,
            longitude,
            dosen:dosen_id (nama) 
          ''');

      listJadwal.assignAll(response as List<dynamic>);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal kuliah: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
