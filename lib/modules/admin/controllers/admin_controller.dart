import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../utils/AppColors.dart';

class AdminController extends GetxController {
  var listDosen = <dynamic>[].obs;
  var listMataKuliah = <dynamic>[].obs;
  var listMahasiswa = <dynamic>[].obs;
  var isLoading = false.obs;

  StreamSubscription? _mkSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    _subscribeToChanges();
  }

  @override
  void onClose() {
    _mkSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToChanges() {
    // Listener untuk perubahan pada tabel mata_kuliah agar UI terupdate real-time
    _mkSubscription = supabase
        .from('mata_kuliah')
        .stream(primaryKey: ['id'])
        .listen((data) {
          // Ketika ada perubahan, kita fetch ulang data untuk memastikan join dosen:dosen_id(nama) juga terupdate
          // Atau kita bisa melakukan optimasi di sini jika datanya sangat besar
          fetchData();
        });
  }

  Future<void> fetchData() async {
    // Only show loading if lists are empty to avoid flickering on real-time updates
    if (listMataKuliah.isEmpty) isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase.from('dosen').select('id, nama, prodi'),
        supabase.from('mata_kuliah').select('id, nama_mk, hari, dosen_id, dosen:dosen_id(nama)'),
        supabase.from('mahasiswa').select('nim, nama'),
      ]);

      listDosen.assignAll(results[0]);
      listMataKuliah.assignAll(results[1]);
      listMahasiswa.assignAll(results[2]);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignDosenToMK(String mkId, String dosenId) async {
    try {
      await supabase
          .from('mata_kuliah')
          .update({'dosen_id': dosenId})
          .eq('id', mkId);
      fetchData();
      Get.back();
      Get.snackbar('Berhasil', 'Dosen berhasil ditugaskan', backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menugaskan dosen: $e', backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> enrollMahasiswaToMK(String nim, String mkId) async {
    try {
      await supabase.from('krs').insert({'nim': nim, 'mk_id': mkId});
      Get.snackbar('Berhasil', 'Mahasiswa berhasil mengambil mata kuliah', backgroundColor: AppColors.success, colorText: Colors.white);
      fetchData(); // Refresh data to show updated enrollment if needed (though listMahasiswa doesn't show KRS yet)
    } catch (e) {
      Get.snackbar('Gagal', 'Mahasiswa mungkin sudah terdaftar di mata kuliah ini.', backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  Future<void> updateMKDay(String mkId, String day) async {
    try {
      await supabase
          .from('mata_kuliah')
          .update({'hari': day})
          .eq('id', mkId);
      fetchData();
      Get.back();
      Get.snackbar('Berhasil', 'Hari mata kuliah berhasil diperbarui', backgroundColor: AppColors.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memperbarui hari: $e', backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }
}
