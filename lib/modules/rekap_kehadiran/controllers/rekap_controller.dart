import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../main.dart';
import '../../../utils/AppColors.dart';
import 'package:geolocator/geolocator.dart';
import '../../../utils/SharedPrefs.dart';

class RekapController extends GetxController {
  var isLoading = true.obs;
  var isGettingLocation = false.obs;
  var isDosen = false.obs;
  
  var nim = ''.obs; // Menggunakan RxString agar UI sinkron
  late String userId;

  // Data Lists
  var listMataKuliah = <Map<String, dynamic>>[].obs;
  var listPresensi = <Map<String, dynamic>>[].obs; // Data presensi milik mahasiswa (P1-P16)
  
  var listSesi = <Map<String, dynamic>>[].obs; // Dropdown pertemuan (Dosen)
  var listMahasiswaKrs = <Map<String, dynamic>>[].obs; // Master list mahasiswa di kelas (Dosen)
  var listReportPresensi = <Map<String, dynamic>>[].obs; // Data kehadiran per sesi (Dosen)
  
  var isSubmitting = false.obs;
  var isLoadingReport = false.obs;

  // Lokasi & Peta
  var tempLat = 0.0.obs;
  var tempLng = 0.0.obs;
  late MapController mapController;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    userId = supabase.auth.currentUser?.id ?? '';
    
    // Ambil NIM awal dari SharedPreferences
    final userData = SharedPrefs.getUserData();
    nim.value = (userData?['nim'] ?? '').toString().trim();
    
    determineRoleAndFetch();
  }

  Future<void> determineRoleAndFetch() async {
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      // 1. Cek Role: Apakah User ini Dosen?
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

        listMataKuliah.assignAll(List<Map<String, dynamic>>.from(mkResponse));
      } else {
        isDosen.value = false;
        
        // 2. Ambil NIM Valid dari profil mahasiswa (auth_id)
        final mhsCheck = await supabase
            .from('mahasiswa')
            .select('nim')
            .eq('auth_id', userId)
            .maybeSingle();
            
        if (mhsCheck != null) {
          nim.value = mhsCheck['nim'].toString().trim();
        }

        final mkResponse = await supabase
            .from('mata_kuliah')
            .select('*, dosen(nama)');
            
        // 3. Ambil data presensi milik mahasiswa ini (untuk grid P1-P16)
        if (nim.value.isNotEmpty) {
          final presensiResponse = await supabase
              .from('presensi')
              .select()
              .ilike('nim_mahasiswa', nim.value);

          listPresensi.assignAll(List<Map<String, dynamic>>.from(presensiResponse));
        }

        listMataKuliah.assignAll(List<Map<String, dynamic>>.from(mkResponse));
      }
    } catch (e) {
      debugPrint("Error determineRole: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA LAPORAN DOSEN: Cara baca database yang akurat ---
  Future<void> fetchReportData(String mkId) async {
    try {
      isLoadingReport.value = true;
      listSesi.clear();
      listMahasiswaKrs.clear();
      listReportPresensi.clear();

      final String cleanMkId = mkId.trim();

      // 1. Ambil Sesi (Dropdown pertemuan 1-16)
      final sesi = await supabase
          .from('sesi_perkuliahan')
          .select()
          .eq('mata_kuliah_id', cleanMkId)
          .order('pertemuan_ke', ascending: true);
      listSesi.assignAll(List<Map<String, dynamic>>.from(sesi));

      // 2. Ambil Data Presensi (Siapa yang sudah hadir/absen)
      // Join ke mahasiswa agar dapat nama langsung
      final presensi = await supabase
          .from('presensi')
          .select('nim_mahasiswa, pertemuan_ke, status, mahasiswa(nama)')
          .eq('mk_id', cleanMkId);
      listReportPresensi.assignAll(List<Map<String, dynamic>>.from(presensi));

      // 3. Ambil Master List dari KRS (Mahasiswa yang WAJIB ada di laporan)
      final krs = await supabase
          .from('krs')
          .select('nim, mahasiswa(nama)')
          .eq('mk_id', cleanMkId);

      // 4. Gabungkan KRS & Presensi (Gunakan Map agar unik dan cepat)
      Map<String, Map<String, dynamic>> masterMahasiswa = {};

      // Masukkan dari KRS
      for (var row in (krs as List)) {
        String sNim = row['nim']?.toString().trim() ?? '';
        if (sNim.isEmpty) continue;
        masterMahasiswa[sNim.toLowerCase()] = {
          'nim': sNim,
          'nama': row['mahasiswa']?['nama']?.toString().trim() ?? 'Mahasiswa $sNim'
        };
      }

      // Pastikan mahasiswa di presensi yang tidak ada di KRS tetap muncul (safety net)
      for (var row in (presensi as List)) {
        String pNim = row['nim_mahasiswa']?.toString().trim() ?? '';
        if (pNim.isNotEmpty && !masterMahasiswa.containsKey(pNim.toLowerCase())) {
          masterMahasiswa[pNim.toLowerCase()] = {
            'nim': pNim,
            'nama': row['mahasiswa']?['nama']?.toString().trim() ?? 'Mahasiswa $pNim'
          };
        }
      }

      final finalList = masterMahasiswa.values.toList();
      finalList.sort((a, b) => a['nama'].toString().toLowerCase().compareTo(b['nama'].toString().toLowerCase()));
      listMahasiswaKrs.assignAll(finalList);

    } catch (e) {
      debugPrint("Error fetchReportData: $e");
    } finally {
      isLoadingReport.value = false;
    }
  }

  // Pencocokan Status Presensi (Tanpa Celah Whitespace/Casing)
  String? getMahasiswaStatus(String? nimMhs, int pKe) {
    if (nimMhs == null || nimMhs.trim().isEmpty) return null;
    final String cleanNim = nimMhs.trim().toLowerCase();

    final record = listReportPresensi.firstWhereOrNull((p) {
      final String dbNim = p['nim_mahasiswa']?.toString().trim().toLowerCase() ?? '';
      final int dbPke = int.tryParse(p['pertemuan_ke'].toString()) ?? 0;
      return dbNim == cleanNim && dbPke == pKe;
    });

    return record?['status'];
  }

  // Digunakan oleh Mahasiswa View (Grid Bulatan P1-16)
  bool checkStatus(String mkId, int pKe) {
    if (nim.value.isEmpty) return false;
    final String targetMkId = mkId.trim().toLowerCase();
    final String cleanNim = nim.value.trim().toLowerCase();
    
    return listPresensi.any((p) {
      final String pMkId = p['mk_id']?.toString().trim().toLowerCase() ?? '';
      final String pNim = p['nim_mahasiswa']?.toString().trim().toLowerCase() ?? '';
      final int dbPke = int.tryParse(p['pertemuan_ke'].toString()) ?? 0;
      return pMkId == targetMkId && pNim == cleanNim && dbPke == pKe;
    });
  }

  bool isMahasiswaHadir(String? nimMhs, int pKe) => getMahasiswaStatus(nimMhs, pKe) != null;

  // --- Fungsi Penunjang: Peta, GPS, dsb ---
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

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      tempLat.value = position.latitude;
      tempLng.value = position.longitude;
      mapController.move(LatLng(position.latitude, position.longitude), 18.0);
      Get.snackbar('Berhasil', 'Lokasi GPS ditangkap.', backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal GPS', e.toString(), backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> updateJadwalSementara(String mkId, String ruang) async {
    try {
      await supabase.from('mata_kuliah').update({'ruang': ruang, 'latitude': tempLat.value, 'longitude': tempLng.value}).eq('id', mkId);
      if (Get.isBottomSheetOpen ?? false) Get.back();
      Get.snackbar('Sukses', 'Lokasi kelas diperbarui.', backgroundColor: AppColors.success, colorText: Colors.white);
      determineRoleAndFetch();
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }

  Future<void> setPresensi(Map<String, dynamic> mk, DateTime? tgl, TimeOfDay? mulai, TimeOfDay? selesai) async {
    if (tgl == null || mulai == null || selesai == null) {
      Get.snackbar("Gagal", "Lengkapi semua data");
      return;
    }
    try {
      isSubmitting.value = true;
      final String jamMulai = '${mulai.hour.toString().padLeft(2, '0')}:${mulai.minute.toString().padLeft(2, '0')}:00';
      final String jamSelesai = '${selesai.hour.toString().padLeft(2, '0')}:${selesai.minute.toString().padLeft(2, '0')}:00';

      final lastSession = await supabase.from('sesi_perkuliahan').select('pertemuan_ke').eq('mata_kuliah_id', mk['id']).order('pertemuan_ke', ascending: false).limit(1);
      int pKe = lastSession.isNotEmpty ? (lastSession.first['pertemuan_ke'] as int) + 1 : 1;

      await supabase.from('sesi_perkuliahan').insert({
        'mata_kuliah_id': mk['id'],
        'dosen_id': mk['dosen_id'],
        'pertemuan_ke': pKe,
        'tanggal_presensi': tgl.toIso8601String().split('T')[0],
        'jam_presensi_dimulai': jamMulai,
        'jam_presensi_berakhir': jamSelesai,
      });

      Get.back();
      Get.snackbar("Berhasil", "Sesi Pertemuan $pKe Dibuka", backgroundColor: AppColors.success, colorText: Colors.white);
      determineRoleAndFetch();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}
