import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
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

    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/images/logo_umm.png'), context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── BACKGROUND ANIMATED CIRCLES (Max Intensity) ──────────
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
                      stops: const [0.5, 1.0], // Area solid lebih luas
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

          // ── GLASSMORPHISM BLUR (Sigma dikurangi agar tajam) ──────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
          ),

          // ── CONTENT ───────────────────────────────────────────────
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Hero(
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
                ),
                const Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black12),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Universitas Muhammadiyah Malang",
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
