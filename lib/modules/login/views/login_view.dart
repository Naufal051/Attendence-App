import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../utils/AppColors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final LoginController controller = Get.find();
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── BACKGROUND ANIMATED CIRCLES ──────────────────────────
          AnimatedBuilder(
            animation: _controller1,
            builder: (context, child) {
              return Positioned(
                top: 100 + (50 * _controller1.value),
                left: -50 + (100 * _controller1.value),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(1.0),
                        Colors.blueAccent.withOpacity(0.0),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller2,
            builder: (context, child) {
              return Positioned(
                bottom: 100 + (50 * _controller2.value),
                right: -50 + (100 * _controller2.value),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(1.0),
                        Colors.purpleAccent.withOpacity(0.0),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── GLASSMORPHISM BLUR ────────────────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── CONTENT ───────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo_umm',
                      createRectTween: (begin, end) {
                        return MaterialRectCenterArcTween(begin: begin, end: end);
                      },
                      flightShuttleBuilder: (context, animation, direction, fromHero, toHero) {
                        return FadeTransition(
                          opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
                          child: toHero.widget,
                        );
                      },
                      child: Image.asset(
                        'assets/images/logo_umm.png',
                        height: 120,
                        fit: BoxFit.contain,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'My Presence UMM',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Universitas Muhammadiyah Malang',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // ── LOGIN CONTAINER ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Silakan Masuk',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── INPUT NIM / EMAIL ────────────────────────
                          const Text(
                            "NIM atau Email",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.identifierCtrl,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Masukkan NIM / Email',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── INPUT PASSWORD ───────────────────────────
                          const Text(
                            "Password",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => TextField(
                            controller: controller.passwordCtrl,
                            obscureText: !controller.isPasswordVisible.value,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Masukkan Password',
                              hintStyle: const TextStyle(color: Colors.black38),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.black54,
                                ),
                                onPressed: () => controller.isPasswordVisible.toggle(),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                          )),
                          const SizedBox(height: 32),

                          // ── TOMBOL MASUK ─────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () => controller.doLogin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.primary.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

                    const SizedBox(height: 32),

                    // ── LUPA PASSWORD ─────────────────────────────────
                    TextButton(
                      onPressed: () {
                        Get.snackbar(
                          'Lupa Password?',
                          'Silakan hubungi Admin Infokom untuk reset password Anda.',
                          backgroundColor: Colors.white,
                          colorText: Colors.black,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                          duration: const Duration(seconds: 4),
                        );
                      },
                      child: const Text(
                        'Lupa Password? Hubungi Admin Infokom',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
