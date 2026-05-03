import 'package:get/get.dart';
import '../../../main.dart'; // Menyesuaikan path ke main.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  // Variabel umum
  var role = "mahasiswa".obs;
  var namaMhs = "".obs;
  var prodi = "".obs;

// Variabel untuk lokasi
  var lokasiSaatini = "Mencari lokasi...".obs;

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
    _dapatkanLokasi();
  }

  void _generateFotoUrl() {
    if (nim.value.length >= 4) {
      String folder = nim.value.substring(0, 4);
      fotoUrl.value = "https://krs.umm.ac.id/Poto/$folder/${nim.value}.JPG";
    }
  }

// Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _dapatkanLokasi() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        lokasiSaatini.value = "Layanan lokasi tidak aktif.";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          lokasiSaatini.value = "Izin lokasi ditolak.";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        lokasiSaatini.value = "Izin lokasi ditolak secara permanen.";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Ambil data kecamatan dan kota
        String kecamatan = place.subLocality ?? "";
        String kota = place.locality ?? "";

        if (kecamatan.isNotEmpty && kota.isNotEmpty) {
          lokasiSaatini.value = "$kecamatan, $kota";
        } else if (kota.isNotEmpty) {
          lokasiSaatini.value = kota;
        } else if (kecamatan.isNotEmpty) {
          lokasiSaatini.value = kecamatan;
        } else {
          lokasiSaatini.value = "Lokasi Ditemukan";
        }
        
      } else {
        lokasiSaatini.value = "Lokasi tidak ditemukan.";
      }
    } catch (e) {
      lokasiSaatini.value = "Gagal mendapatkan lokasi: $e";
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
