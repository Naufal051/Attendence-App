import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../utils/AppColors.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  final LoginController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── LOGO ──────────────────────────────────────────
                //logo UMM
                // Image.asset('assets/images/logo_umm.png', height: 100)
                Image.asset(
                  'assets/images/logo_umm.png',
                  height: 120,
                ),

                const SizedBox(height: 16),
                const Text(
                  'My Presence UMM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Universitas Muhammadiyah Malang',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // ── CARD FORM ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Silakan Masuk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── INPUT NIM / EMAIL ────────────────────────
                      TextField(
                        controller: controller.identifierCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'NIM atau Email',
                          hintText: 'Masukkan NIM / Email Anda',
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── INPUT PASSWORD + SHOW/HIDE ───────────────
                      Obx(() => TextField(
                            controller: controller.passwordCtrl,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Masukkan Password Anda',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.primary,
                                ),
                                onPressed: () =>
                                    controller.isPasswordVisible.toggle(),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),

                      // ── REMEMBER ME ──────────────────────────────
                      Obx(() => Row(
                            children: [
                              Checkbox(
                                value: controller.rememberMe.value,
                                activeColor: AppColors.primary,
                                onChanged: (val) =>
                                    controller.rememberMe.value = val ?? false,
                              ),
                              const Text('Ingat saya selama 30 hari'),
                            ],
                          )),
                      const SizedBox(height: 12),

                      // ── TOMBOL MASUK ─────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.doLogin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'MASUK',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── LUPA PASSWORD ─────────────────────────────────
                TextButton(
                  onPressed: () {
                    Get.snackbar(
                      'Lupa Password?',
                      'Silakan hubungi Admin Infokom untuk reset password Anda.',
                      backgroundColor: Colors.white,
                      colorText: AppColors.primary,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  child: const Text(
                    'Lupa Password? Hubungi Admin Infokom',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}