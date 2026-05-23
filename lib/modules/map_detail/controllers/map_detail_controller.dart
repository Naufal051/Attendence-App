import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../main.dart';
import '../../../utils/AppColors.dart';
import '../../rekap_kehadiran/controllers/rekap_controller.dart';

class MapDetailController extends GetxController {
  var isLoadingLocation = true.obs;
  var isSubmitting = false.obs;
  var isAlreadyAttended = false.obs;
  var myLocation = Rxn<LatLng>();
  var distanceInMeters = 0.obs;
  var sesiAktif = Rxn<Map<String, dynamic>>();

  final int maxRadius = 50;

  Future<void> checkExistingAttendance(String mkId, String nim) async {
    try {
      final cleanNim = nim.trim();
      final now = DateTime.now();
      final todayStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();
      final todayEnd = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      ).toIso8601String();

      final response = await supabase
          .from('presensi')
          .select()
          .eq('mk_id', mkId)
          .eq('nim_mahasiswa', cleanNim)
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

  Future<void> fetchLocation(
    LatLng targetKelas,
    String mkId,
    String nim,
  ) async {
    isLoadingLocation.value = true;
    await checkExistingAttendance(mkId, nim);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Layanan GPS tidak aktif.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw 'Izin lokasi ditolak.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (position.isMocked) {
        throw 'Sistem mendeteksi penggunaan Fake GPS!';
      }

      myLocation.value = LatLng(position.latitude, position.longitude);
      calculateDistance(targetKelas);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void calculateDistance(LatLng targetKelas) {
    if (myLocation.value != null) {
      const distanceHelper = Distance();
      distanceInMeters.value = distanceHelper
          .as(LengthUnit.Meter, myLocation.value!, targetKelas)
          .toInt();
    }
  }

  Future<void> prosesPresensi(
    Map<String, dynamic> mataKuliahData,
    String nimMahasiswa,
  ) async {
    if (myLocation.value == null || isAlreadyAttended.value) return;

    // Gunakan radius dari database atau default 50 meter
    final int effectiveRadius = mataKuliahData['radius_meter'] ?? maxRadius;

    /// VALIDASI RADIUS
    if (distanceInMeters.value > effectiveRadius) {
      Get.snackbar(
        'Gagal',
        'Anda berada di luar radius presensi (${distanceInMeters.value}m / ${effectiveRadius}m)!',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final String mkId = mataKuliahData['id'];

      /// AMBIL TANGGAL HARI INI
      final today = DateTime.now().toIso8601String().split('T')[0];

      /// FETCH SESI PERKULIAHAN HARI INI
      final sesiResponse = await supabase
          .from('sesi_perkuliahan')
          .select()
          .eq('mata_kuliah_id', mkId)
          .eq('tanggal_presensi', today)
          .order('pertemuan_ke', ascending: false)
          .limit(1);

      /// JIKA DOSEN BELUM MEMBUKA PRESENSI
      if (sesiResponse.isEmpty) {
        Get.snackbar(
          'Presensi Ditutup',
          'Belum ada sesi presensi yang dibuka dosen hari ini.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      final sesi = sesiResponse.first;

      /// AMBIL JAM PRESENSI
      final String jamMulai = sesi['jam_presensi_dimulai'];
      final String jamSelesai = sesi['jam_presensi_berakhir'];

      final now = DateTime.now();

      final mulai = DateTime.parse('${today} ${jamMulai}');

      final selesai = DateTime.parse('${today} ${jamSelesai}');

      /// VALIDASI RENTANG WAKTU
      if (now.isBefore(mulai) || now.isAfter(selesai)) {
        Get.snackbar(
          'Presensi Ditutup',
          'Presensi hanya dapat dilakukan pada jam '
              '$jamMulai - $jamSelesai',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );

        return;
      }

      /// CEK APAKAH SUDAH ABSEN DI PERTEMUAN INI
      final cleanNim = nimMahasiswa.trim();
      final existingAttendance = await supabase
          .from('presensi')
          .select()
          .eq('nim_mahasiswa', cleanNim)
          .eq('mk_id', mkId)
          .eq('pertemuan_ke', sesi['pertemuan_ke']);

      if (existingAttendance.isNotEmpty) {
        isAlreadyAttended.value = true;

        Get.snackbar(
          'Info',
          'Anda sudah melakukan presensi pada pertemuan ini.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        return;
      }

      /// INSERT PRESENSI
      await supabase.from('presensi').insert({
        'nim_mahasiswa': nimMahasiswa.trim(),
        'mk_id': mkId,
        'pertemuan_ke': sesi['pertemuan_ke'],
        'status': 'Hadir',
        'waktu_presensi': DateTime.now().toIso8601String(),
      });

      // Update rekap jika controller tersedia
      if (Get.isRegistered<RekapController>()) {
        Get.find<RekapController>().determineRoleAndFetch();
      }

      isAlreadyAttended.value = true;

      Get.snackbar(
        'Sukses!',
        'Presensi pertemuan ke-${sesi['pertemuan_ke']} berhasil dicatat!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchSesiAktif(String mkId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await supabase
          .from('sesi_perkuliahan')
          .select()
          .eq('mata_kuliah_id', mkId)
          .eq('tanggal_presensi', today)
          .order('pertemuan_ke', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        sesiAktif.value = response.first;
      } else {
        sesiAktif.value = null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
