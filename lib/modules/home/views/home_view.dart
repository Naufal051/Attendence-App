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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Obx(() => Text(
          controller.role.value == 'dosen' ? 'Dashboard Dosen' : 'Jadwal Hari Ini',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Get.offAll(LoginView());
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Profil (Dinamis Berdasarkan Role) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: [
                // FOTO PROFIL DENGAN FALLBACK
                Obx(() => CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: controller.role.value == 'mahasiswa' && controller.fotoUrl.isNotEmpty
                        ? Image.network(
                      controller.fotoUrl.value,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 40, color: AppColors.primary);
                      },
                    )
                        : const Icon(Icons.person, size: 40, color: AppColors.primary),
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
                      )),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.role.value == 'mahasiswa') {
                          return Text(
                            '${controller.nim.value} | ${controller.prodi.value}',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.fakultas.value} | ${controller.prodi.value}',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                              ),
                              Text(
                                controller.email.value,
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
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
          ),

          const SizedBox(height: 20),

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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Mata Kuliah Hari Ini',
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

                        final String namaMk = mk['nama_mk']?.toString() ?? 'Mata Kuliah';
                        final String jamMulai = mk['jam_mulai']?.toString().substring(0, 5) ?? '--:--';
                        final String jamSelesai = mk['jam_selesai']?.toString().substring(0, 5) ?? '--:--';
                        final String ruang = mk['ruang']?.toString() ?? '-';

                        String namaDosen = 'Dosen Pengampu';
                        if (mk['dosen'] != null && mk['dosen'] is Map) {
                          namaDosen = mk['dosen']['nama']?.toString() ?? 'Dosen Pengampu';
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Get.to(() => MapDetailView(
                                mataKuliahData: mk,
                                nimMahasiswa: controller.nim.value,
                              ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.access_time_filled, color: AppColors.primary, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          namaMk,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(namaDosen, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule, size: 14, color: AppColors.textLight),
                                            const SizedBox(width: 4),
                                            Text('$jamMulai - $jamSelesai WIB', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.meeting_room, size: 14, color: AppColors.textLight),
                                            const SizedBox(width: 4),
                                            Text(ruang, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 18)
                                ],
                              ),
                            ),
                          ),
                        );
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
}
