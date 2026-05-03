import 'package:attendence_app/app_routes/app_routes.dart';
import 'package:attendence_app/modules/map_detail/views/map_detail_view.dart' hide AppColors;
import 'package:attendence_app/modules/login/views/login_view.dart';
import 'package:attendence_app/modules/rekap_kehadiran/views/rekap_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart'; // Updated relative import
import 'package:attendence_app/utils/AppColors.dart';

// ==========================================
// 4. TAMPILAN NAVIGASI UTAMA (Bottom Nav)
// ==========================================
class MainNavView extends StatefulWidget {
  const MainNavView({Key? key}) : super(key: key);

  @override
  State<MainNavView> createState() => _MainNavViewState();
}

class _MainNavViewState extends State<MainNavView> {
  int _currentIndex = 0;

  // Inisialisasi Controller di sini agar bisa diakses untuk penentuan halaman
  final HomeController controller = Get.put(HomeController());

  // Daftar halaman navigasi
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeView(),
      RekapView(), // Mengarahkan ke halaman rekap asli
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
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
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  final HomeController controller = Get.find<HomeController>();

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return 'Selamat Pagi 👋,';
    } else if (hour >= 10 && hour < 15) {
      return 'Selamat Siang ☀️,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore ☕,';
    } else {
      return 'Selamat Malam 🌙,';
    }
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
          // --- Header Profil (Dinamis Berdasarkan Role) ---
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: const TextStyle(
                          color: Colors.black54, 
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                        controller.namaMhs.value,
                        style: const TextStyle(
                          color: Colors.black87, 
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.black87, size: 28),
                  onPressed: () { // Reset satu-satu manual tanpa mematikan controller
                    controller.role.value = '';
                    controller.namaMhs.value = '';
                    controller.nim.value = '';
                    controller.fotoUrl.value = '';
                    controller.listJadwal.clear();

                    Get.offAll(() => LoginView());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24), 
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // FOTO PROFIL DENGAN FALLBACK
                    Obx(() => Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2), 
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: controller.role.value == 'mahasiswa' && controller.fotoUrl.isNotEmpty
                              ? Image.network(
                                  controller.fotoUrl.value,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 35, color: AppColors.primary);
                                  },
                                )
                              : const Icon(Icons.person, size: 35, color: AppColors.primary),
                        ),
                      ),
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                            controller.namaMhs.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          const SizedBox(height: 6),
                          Obx(() {
                            if (controller.role.value == 'mahasiswa') {
                              return Text(
                                '${controller.nim.value} | ${controller.prodi.value}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.fakultas.value} | ${controller.prodi.value}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                  ),
                                  Text(
                                    controller.email.value,
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                                  ),
                                ],
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(
                            tanggalSekarang,
                            style: const TextStyle(
                              color: Colors.black87, 
                              fontSize: 13, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_city_outlined, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          const SizedBox(width: 8),
                          Obx(()=> Text (
                            controller.lokasiSaatini.value,
                            style: const TextStyle(
                              color: Colors.black87, 
                              fontSize: 13, 
                              fontWeight: FontWeight.w600
                            ) 
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Bagian Utama (Kondisional: Mata Kuliah vs Pertemuan) ---
          Expanded(
            child: Obx(() {
              // Jika DOSEN: Tampilkan Ringkasan Pertemuan/Rekap
              if (controller.role.value == 'dosen') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Ringkasan Kelas Mengajar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RekapView(), // Menampilkan daftar pertemuan langsung di Home
                    ),
                  ],
                );
              }

              // Jika MAHASISWA: Tampilkan Daftar Mata Kuliah Hari Ini
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (controller.listJadwal.isEmpty) {
                return const Center(child: Text("Tidak ada jadwal mata kuliah."));
              }

              // logika jadwal terdekat
              final currentMinutes = now.hour * 60 + now.minute;
              Map<String, dynamic>? jadwalTerdekat;

              for (var item in controller.listJadwal) {
                try {
                  final mk = item as Map<String, dynamic>;
                  final jamSelesaiStr = mk['jam_selesai']?.toString() ?? '';
                  
                  if (jamSelesaiStr.length >= 5) {
                    final cleanTime = jamSelesaiStr.substring(0, 5);
                    final parts = cleanTime.split(':');
                    if (parts.length >= 2) {
                      final selesaiMinutes = int.parse(parts[0].trim()) * 60 + int.parse(parts[1].trim());
                      if (selesaiMinutes > currentMinutes) {
                        jadwalTerdekat = mk;
                        break;
                      }
                    }
                  }
                } catch (e) {
                  continue;
                }
              }
              jadwalTerdekat ??= controller.listJadwal.last as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Jadwal Terdekat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // card jadwal terdekat
                    child: _buildJadwalCard(jadwalTerdekat, isTerdekat: true),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Jadwal Kuliah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.listJadwal.length,
                      itemBuilder: (context, index) {
                        final mk = controller.listJadwal[index] as Map<String, dynamic>;
                        return _buildJadwalCard(mk, isTerdekat: false);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget _buildJadwalCard yang diekstrak 
  Widget _buildJadwalCard(Map<String, dynamic> mk, {required bool isTerdekat}) {
    final String namaMk = mk['nama_mk']?.toString() ?? 'Mata Kuliah';
    final String rawJamMulai = mk['jam_mulai']?.toString() ?? '--:--';
    final String rawJamSelesai = mk['jam_selesai']?.toString() ?? '--:--';
    final String jamMulai = rawJamMulai.length >= 5 ? rawJamMulai.substring(0, 5) : rawJamMulai;
    final String jamSelesai = rawJamSelesai.length >= 5 ? rawJamSelesai.substring(0, 5) : rawJamSelesai;
    
    final String ruang = mk['ruang']?.toString() ?? '-';

    String namaDosen = 'Dosen Pengampu';
    if (mk['dosen'] != null && mk['dosen'] is Map) {
      namaDosen = mk['dosen']['nama']?.toString() ?? 'Dosen Pengampu';
    }

    return Container(
      margin: EdgeInsets.only(bottom: isTerdekat ? 0 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isTerdekat
              ? [Colors.white, AppColors.primary.withOpacity(0.04)]
              : [Colors.white, Colors.grey.shade50],
        ),
        border: isTerdekat 
            ? Border.all(color: AppColors.primary.withOpacity(0.6), width: 1.5) 
            : Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: isTerdekat ? AppColors.primary.withOpacity(0.25) : Colors.grey.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(5, 6),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => MapDetailView(
              mataKuliahData: mk,
              nimMahasiswa: controller.nim.value,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Icon Background
                Container(
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time_filled, 
                    color: AppColors.primary, 
                    size: 24 
                  ),
                ),
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isTerdekat) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                          decoration: BoxDecoration(
                            color: AppColors.primary, 
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          ),
                          child: const Text("SEDANG / AKAN BERLANGSUNG", style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                        const SizedBox(height: 6), 
                      ],
                      Text(
                        namaMk,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15, 
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4), // Jarak 
                      Text(namaDosen, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                      const SizedBox(height: 6), // Jarak 
                      
                      // Informasi Jam dan Ruang
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Text('$jamMulai - $jamSelesai WIB', style: const TextStyle(fontSize: 10.5, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              children: [
                                const Icon(Icons.meeting_room, size: 12, color: AppColors.textLight),
                                const SizedBox(width: 4),
                                Text(ruang, style: const TextStyle(fontSize: 10.5, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}