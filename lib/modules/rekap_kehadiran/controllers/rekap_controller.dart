import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../main.dart';
import '../../../utils/AppColors.dart';
import 'package:geolocator/geolocator.dart';

class RekapController extends GetxController {
  var isLoading = true.obs;
  var isGettingLocation = false.obs;
  var isDosen = false.obs;
  var listMataKuliah = <Map<String, dynamic>>[].obs;
  var listPresensi = <Map<String, dynamic>>[].obs;

  var tempLat = 0.0.obs;
  var tempLng = 0.0.obs;

  late MapController mapController;

  final String nim = Get.arguments?['nim'] ?? '';
  final String userId = supabase.auth.currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    determineRoleAndFetch();
  }

  Future<void> determineRoleAndFetch() async {
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final dosenCheck = await supabase
          .from('dosen')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();

      if (dosenCheck != null) {
        isDosen.value = true;
        final mkResponse = await supabase
            .from('mata_kuliah')
            .select('*, dosen(nama)')
            .eq('dosen_id', dosenCheck['id']);

        listMataKuliah.value = List<Map<String, dynamic>>.from(mkResponse);
      } else {
        isDosen.value = false;
        final mkResponse = await supabase.from('mata_kuliah').select('*, dosen(nama)');
        final presensiResponse = await supabase.from('presensi').select().eq('nim_mahasiswa', nim);

        listMataKuliah.value = List<Map<String, dynamic>>.from(mkResponse);
        listPresensi.value = List<Map<String, dynamic>>.from(presensiResponse);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> catchCurrentLocation() async {
    isGettingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS tidak aktif.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation
      );

      tempLat.value = position.latitude;
      tempLng.value = position.longitude;

      mapController.move(LatLng(position.latitude, position.longitude), 18.0);

      Get.snackbar('Berhasil', 'Peta telah diarahkan ke lokasi GPS Anda.',
          backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal GPS', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> updateJadwalSementara(String mkId, String ruang) async {
    try {
      await supabase.from('mata_kuliah').update({
        'ruang': ruang,
        'latitude': tempLat.value,
        'longitude': tempLng.value,
      }).eq('id', mkId);

      if (Get.isBottomSheetOpen ?? false) Get.back();

      Get.snackbar('Sukses', 'Titik presensi kelas berhasil diperbarui.',
          backgroundColor: AppColors.success, colorText: Colors.white);
      determineRoleAndFetch();
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  bool checkStatus(String mkId, int pertemuan) {
    return listPresensi.any((p) => p['mk_id'] == mkId && p['pertemuan_ke'] == pertemuan);
  }
}
