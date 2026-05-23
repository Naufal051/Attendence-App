import 'package:attendence_app/app_routes/app_routes.dart';
import 'package:attendence_app/modules/map_detail/views/map_detail_view.dart';
import 'package:attendence_app/modules/login/views/login_view.dart';
import 'package:attendence_app/modules/rekap_kehadiran/views/rekap_view.dart';
import 'package:attendence_app/utils/SharedPrefs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:attendence_app/utils/AppColors.dart';
import 'package:attendence_app/modules/admin/views/admin_view.dart';

class MainNavView extends StatefulWidget {
  const MainNavView({Key? key}) : super(key: key);

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  int _currentIndex = 0;
  final HomeController controller = Get.put(HomeController());
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    if (controller.role.value == 'admin') {
      _pages = [
        const AdminView(),
        const Center(child: Text("Admin Profile/Settings")),
      ];
    } else {
      _pages = [
        HomeView(),
        RekapView(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) => setState(() => _currentIndex = index),
        items: controller.role.value == 'admin' 
          ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'Manage',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_edu_outlined),
                activeIcon: Icon(Icons.history_edu),
                label: 'Kehadiran',
              ),
            ],
      )),
    );
  }
}

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final HomeController controller = Get.find<HomeController>();

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'Selamat Pagi 👋,';
    if (hour >= 10 && hour < 15) return 'Selamat Siang ☀️,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore ☕,';
    return 'Selamat Malam 🌙,';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final String tanggalSekarang = '${now.day.toString().padLeft(2, '0')} ${bulan[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Profil ---
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getGreeting(), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                        controller.namaMhs.value,
                        style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.black87, size: 28),
                  onPressed: () async {
                    await SharedPrefs.clear();
                    Get.offAllNamed(Routes.LOGIN);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Card Profil ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: controller.fotoUrl.isNotEmpty
                            ? Image.network(
                                controller.fotoUrl.value,
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                              )
                            : const Icon(Icons.person, color: AppColors.primary),
                      ),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            controller.namaMhs.value,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                            '${controller.nim.value} | ${controller.prodi.value}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(tanggalSekarang, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Obx(() => Text(
                                controller.lokasiSaatini.value,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Daftar Jadwal ---
          Expanded(
            child: Obx(() {
              if (controller.role.value == 'dosen') return RekapView();
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (controller.jadwalTerdekat.value != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text('Jadwal Terdekat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ),
                    _buildJadwalCard(controller.jadwalTerdekat.value!, isTerdekat: true),
                    const SizedBox(height: 20),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text('Jadwal Kuliah Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ),
                  if (controller.jadwalHariIni.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada jadwal yang tersedia.")))
                  else
                    ...controller.jadwalHariIni.map((mk) => _buildJadwalCard(mk, isTerdekat: false)),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                    child: Text('Seluruh Jadwal Kuliah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ),
                  if (controller.listJadwal.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Data mata kuliah kosong di database.")))
                  else
                    ...controller.listJadwal.map((mk) => _buildJadwalCard(mk, isTerdekat: false)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> mk, {required bool isTerdekat}) {
    final String namaMk = mk['nama_mk'] ?? 'Mata Kuliah';
    
    // Penanganan aman untuk string waktu
    String jamMulai = mk['jam_mulai']?.toString() ?? '00:00:00';
    String jamSelesai = mk['jam_selesai']?.toString() ?? '00:00:00';
    if (jamMulai.length >= 5) jamMulai = jamMulai.substring(0, 5);
    if (jamSelesai.length >= 5) jamSelesai = jamSelesai.substring(0, 5);
    
    final String jam = '$jamMulai - $jamSelesai';
    final String ruang = mk['ruang'] ?? '-';
    final String hari = mk['hari'] ?? '-';
    final String dosen = mk['dosen']?['nama'] ?? 'Dosen Pengampu';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTerdekat 
              ? [Colors.white, AppColors.primary.withValues(alpha: 0.05)] 
              : [Colors.white, Colors.grey.shade50],
        ),
        border: isTerdekat ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5) : Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: isTerdekat ? AppColors.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => MapDetailView(mataKuliahData: mk, nimMahasiswa: controller.nim.value)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.access_time_filled, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTerdekat) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                          child: const Text("SEDANG BERLANGSUNG", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        namaMk, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isTerdekat ? Colors.black : AppColors.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dosen, 
                        style: TextStyle(fontSize: 13, color: isTerdekat ? Colors.black87 : AppColors.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _badge(hari, Colors.blue),
                          _badge(jam, Colors.orange),
                          _badge(ruang, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: isTerdekat ? AppColors.primary : Colors.grey.shade400, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    // Gunakan warna yang lebih gelap untuk teks agar kontras lebih baik
    Color textColor = color;
    if (color == Colors.blue) textColor = Colors.blue.shade900;
    if (color == Colors.orange) textColor = Colors.orange.shade900;
    if (color == Colors.green) textColor = Colors.green.shade900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12), 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1)
      ),
      child: Text(
        text, 
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)
      ),
    );
  }
}
