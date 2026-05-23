import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import 'package:attendence_app/utils/AppColors.dart';
import 'package:attendence_app/utils/SharedPrefs.dart';
import 'package:attendence_app/app_routes/app_routes.dart';

class AdminView extends StatelessWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await SharedPrefs.clear();
                Get.offAllNamed(Routes.LOGIN);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manajemen MK', icon: Icon(Icons.book)),
              Tab(text: 'Manajemen KRS', icon: Icon(Icons.people)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildMKManagement(controller),
            _buildKRSManagement(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMKManagement(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

      return ListView.builder(
        itemCount: controller.listMataKuliah.length,
        itemBuilder: (context, index) {
          final mk = controller.listMataKuliah[index];
          final dosenNama = mk['dosen']?['nama'] ?? 'Belum ada dosen';
          final hari = mk['hari'] ?? 'Belum diatur';

          return ListTile(
            title: Text(mk['nama_mk'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Dosen: $dosenNama\nHari: $hari'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
                  tooltip: 'Update Hari',
                  onPressed: () => _showUpdateDayDialog(context, controller, mk['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add, color: AppColors.primary, size: 20),
                  tooltip: 'Tugaskan Dosen',
                  onPressed: () => _showAssignDosenDialog(context, controller, mk['id']),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildKRSManagement(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

      return ListView.builder(
        itemCount: controller.listMahasiswa.length,
        itemBuilder: (context, index) {
          final mhs = controller.listMahasiswa[index];

          return ListTile(
            title: Text(mhs['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('NIM: ${mhs['nim']}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showEnrollMKDialog(context, controller, mhs['nim']),
            ),
          );
        },
      );
    });
  }

  void _showUpdateDayDialog(BuildContext context, AdminController controller, String mkId) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Hari'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: days.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(days[index]),
                onTap: () => controller.updateMKDay(mkId, days[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAssignDosenDialog(BuildContext context, AdminController controller, String mkId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tugaskan Dosen'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.listDosen.length,
            itemBuilder: (context, index) {
              final dosen = controller.listDosen[index];
              return ListTile(
                title: Text(dosen['nama']),
                subtitle: Text(dosen['prodi']),
                onTap: () => controller.assignDosenToMK(mkId, dosen['id']),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEnrollMKDialog(BuildContext context, AdminController controller, String nim) {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Mata Kuliah'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.listMataKuliah.length,
            itemBuilder: (context, index) {
              final mk = controller.listMataKuliah[index];
              return ListTile(
                title: Text(mk['nama_mk']),
                onTap: () {
                  controller.enrollMahasiswaToMK(nim, mk['id']);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
