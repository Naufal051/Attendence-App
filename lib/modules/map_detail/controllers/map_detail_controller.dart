import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../main.dart';
import '../../../utils/AppColors.dart';

class MapDetailController extends GetxController {
  var isLoadingLocation = true.obs;
  var isSubmitting = false.obs;
  var isAlreadyAttended = false.obs;
  var myLocation = Rxn<LatLng>();
  var distanceInMeters = 0.obs;

  final int maxRadius = 50;

  Future<void> checkExistingAttendance(String mkId, String nim) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final response = await supabase
          .from('presensi')
          .select()
          .eq('mk_id', mkId)
          .eq('nim_mahasiswa', nim)
          .gte('waktu_presensi', todayStart)
          .lte('waktu_presensi', todayEnd)
          .maybeSingle();

      if (response != null) {
        isAlreadyAttended.value = true;
      } else {
        isAlreadyAttended.value = false;
      }
    } catch (e) {
      debugPrint("Gagal cek status presensi: $e");
    }
  }

  Future<void> fetchLocation(LatLng targetKelas, String mkId, String nim) async {
    isLoadingLocation.value = true;
    await checkExistingAttendance(mkId, nim);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Layanan GPS tidak aktif.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation
      );

      if (position.isMocked) {
        throw 'Sistem mendeteksi penggunaan Fake GPS!';
      }

      myLocation.value = LatLng(position.latitude, position.longitude);
      calculateDistance(targetKelas);

    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void calculateDistance(LatLng targetKelas) {
    if (myLocation.value != null) {
      const distanceHelper = Distance();
      distanceInMeters.value = distanceHelper.as(
          LengthUnit.Meter,
          myLocation.value!,
          targetKelas
      ).toInt();
    }
  }

  Future<void> prosesPresensi(Map<String, dynamic> mataKuliahData, String nimMahasiswa) async {
    if (myLocation.value == null || isAlreadyAttended.value) return;

    if (distanceInMeters.value > maxRadius) {
      Get.snackbar('Gagal', 'Anda berada di luar radius presensi!', backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final String mkId = mataKuliahData['id'];

      final checkResponse = await supabase
          .from('presensi')
          .select('pertemuan_ke')
          .eq('mk_id', mkId)
          .eq('nim_mahasiswa', nimMahasiswa)
          .order('pertemuan_ke', ascending: false)
          .limit(1);

      int pertemuanSelanjutnya = 1;
      if (checkResponse.isNotEmpty) {
        pertemuanSelanjutnya = (checkResponse[0]['pertemuan_ke'] as int) + 1;
      }

      await supabase.from('presensi').insert({
        'nim_mahasiswa': nimMahasiswa,
        'mk_id': mkId,
        'pertemuan_ke': pertemuanSelanjutnya,
        'status': 'Hadir',
      });

      isAlreadyAttended.value = true;

      Get.snackbar(
          'Sukses!',
          'Presensi Pertemuan $pertemuanSelanjutnya berhasil dicatat!',
          backgroundColor: AppColors.success,
          colorText: Colors.white
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
