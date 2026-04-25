import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart';
import '../../home/views/home_view.dart'; // Mengarah ke lokasi baru HomeView

class LoginController extends GetxController {
  final identifierCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var isLoading = false.obs;

  Future<void> doLogin() async {
    final String identifier = identifierCtrl.text.trim();
    final String password = passwordCtrl.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar('Gagal', 'NIM/Email dan Password wajib diisi!',
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      String authEmail = identifier;

      if (GetUtils.isNumericOnly(identifier)) {
        final mhsData = await supabase
            .from('mahasiswa')
            .select('email')
            .eq('nim', identifier)
            .maybeSingle();

        if (mhsData != null) {
          authEmail = mhsData['email'];
        } else {
          throw 'NIM tidak terdaftar di sistem.';
        }
      }

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: authEmail,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        final results = await Future.wait([
          supabase.from('mahasiswa').select('nim, nama, prodi').eq('auth_id', user.id).maybeSingle(),
          supabase.from('dosen').select('id, nama, prodi, email, fakultas').eq('auth_id', user.id).maybeSingle(),
        ]);

        final dataMahasiswa = results[0];
        final dataDosen = results[1];

        if (dataMahasiswa != null) {
          _handleSuccess(dataMahasiswa, 'mahasiswa');
        } else if (dataDosen != null) {
          _handleSuccess(dataDosen, 'dosen');
        } else {
          throw 'Akun terdaftar namun profil (Role) tidak ditemukan.';
        }
      }
    } on AuthException catch (e) {
      Get.snackbar('Login Gagal', 'Email/NIM atau Password salah.',
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Login Gagal', e.toString().replaceAll('Exception:', ''),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSuccess(Map<String, dynamic>? profileData, String role) {
    if (profileData == null) return;

    if (role == 'dosen') {
      profileData['nim'] = profileData['id'];
    }

    final Map<String, dynamic> userData = {...profileData, 'role': role};

    Get.snackbar(
        'Berhasil',
        'Selamat datang, ${profileData['nama']}!',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP
    );

    Get.offAll(() => const MainNavView(), arguments: userData);
  }

  @override
  void onClose() {
    identifierCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
