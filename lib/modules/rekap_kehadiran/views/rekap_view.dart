import '../controllers/rekap_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../utils/AppColors.dart';

class RekapView extends StatelessWidget {
  RekapView({Key? key}) : super(key: key);

  final RekapController controller = Get.put(RekapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.determineRoleAndFetch();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.listMataKuliah.length,
            itemBuilder: (context, index) {
              final mk = controller.listMataKuliah[index];
              final String mkId = mk['id'];
              final String namaMk = mk['nama_mk'] ?? 'Mata Kuliah';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        controller.isDosen.value
                            ? Icons.assignment_ind
                            : Icons.school,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      namaMk,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      controller.isDosen.value
                          ? 'Atur Lokasi Mengajar'
                          : 'Detail Pertemuan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: controller.isDosen.value
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.analytics_outlined,
                                  color: AppColors.primary,
                                ),
                                tooltip: 'Laporan Presensi',
                                onPressed: () async {
                                  await controller.fetchReportData(mk['id']);
                                  _showReportBottomSheet(context, mk);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.how_to_reg_rounded,
                                  color: AppColors.primary,
                                ),
                                tooltip: 'Buka Presensi',
                                onPressed: () {
                                  _showPresensiDialog(context, mk);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_location_alt_rounded,
                                  color: AppColors.primary,
                                ),
                                tooltip: 'Atur Lokasi',
                                onPressed: () {
                                  controller.tempLat.value = mk['latitude'];
                                  controller.tempLng.value = mk['longitude'];
                                  _showEditDialog(context, mk);
                                },
                              ),
                            ],
                          )
                        : const Icon(Icons.expand_more, color: Colors.grey),
                    children: [
                      if (!controller.isDosen.value) ...[
                        Divider(color: Colors.grey.shade200, height: 1),
                        _buildMahasiswaGrid(mkId),
                      ] else ...[
                        Divider(color: Colors.grey.shade200, height: 1),
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          title: const Text("Lokasi Terdaftar"),
                          subtitle: Text(
                            "Ruang: ${mk['ruang']} (${mk['latitude']}, ${mk['longitude']})",
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMahasiswaGrid(String mkId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 16,
        itemBuilder: (context, i) {
          int p = i + 1;
          bool hadir = controller.checkStatus(mkId, p);
          return Container(
            decoration: BoxDecoration(
              color: hadir
                  ? AppColors.success.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hadir ? AppColors.success : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                "P$p",
                style: TextStyle(
                  color: hadir ? AppColors.success : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> mk) {
    final ruangCtrl = TextEditingController(text: mk['ruang']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tentukan Lokasi Kelas",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Geser peta untuk memposisikan titik merah tepat di lokasi kelas Anda.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            mk['latitude'],
                            mk['longitude'],
                          ),
                          initialZoom: 17.5,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture) {
                              controller.tempLat.value =
                                  position.center.latitude;
                              controller.tempLng.value =
                                  position.center.longitude;
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.attendance.app',
                          ),
                        Obx(() => CircleLayer(
                            circles: [
                              CircleMarker(
                                point: LatLng(
                                  controller.tempLat.value,
                                  controller.tempLng.value,
                                ),
                                radius: 50,
                                useRadiusInMeter: true,
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderStrokeWidth: 2,
                                borderColor: AppColors.primary,
                              ),
                            ],
                          )),
                        ],
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 35),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 45,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: FloatingActionButton.small(
                          onPressed: () => controller.catchCurrentLocation(),
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Obx(
                () => Text(
                  "Koordinat: ${controller.tempLat.value.toStringAsFixed(6)}, ${controller.tempLng.value.toStringAsFixed(6)}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: ruangCtrl,
                decoration: InputDecoration(
                  labelText: "Nama Ruangan",
                  prefixIcon: const Icon(Icons.meeting_room),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.updateJadwalSementara(mk['id'], ruangCtrl.text);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("SIMPAN TITIK LOKASI"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showPresensiDialog(BuildContext context, Map<String, dynamic> mk) {
    final selectedDate = Rxn<DateTime>();
    final openTime = Rxn<TimeOfDay>();
    final closeTime = Rxn<TimeOfDay>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Set Presensi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tentukan tanggal dan waktu presensi mahasiswa.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              /// DATE PICKER
              Obx(
                () => TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Tanggal Presensi",
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: TextEditingController(
                    text: selectedDate.value == null
                        ? ''
                        : "${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}",
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// TIME PICKER OPEN
              Obx(
                () => TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Waktu Presensi Dibuka",
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: TextEditingController(
                    text: openTime.value?.format(context) ?? '',
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      openTime.value = picked;
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// TIME PICKER CLOSE
              Obx(
                () => TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Waktu Presensi Ditutup",
                    prefixIcon: const Icon(Icons.access_time_filled),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: TextEditingController(
                    text: closeTime.value?.format(context) ?? '',
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      closeTime.value = picked;
                    }
                  },
                ),
              ),

              const SizedBox(height: 32),

              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () {
                              controller.setPresensi(
                                mk,
                                selectedDate.value,
                                openTime.value,
                                closeTime.value,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "BUKA PRESENSI SEKARANG",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showReportBottomSheet(BuildContext context, Map<String, dynamic> mk) {
    final selectedSesi = Rxn<Map<String, dynamic>>();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Obx(() {
          if (controller.isLoadingReport.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.listSesi.isEmpty) {
            return const Center(child: Text("Belum ada sesi perkuliahan."));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Laporan: ${mk['nama_mk']}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              
              // Dropdown Sesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    hint: const Text("Pilih Pertemuan"),
                    value: selectedSesi.value,
                    items: controller.listSesi.map((sesi) {
                      return DropdownMenuItem(
                        value: sesi,
                        child: Text("Pertemuan ${sesi['pertemuan_ke']} (${sesi['tanggal_presensi']})"),
                      );
                    }).toList(),
                    onChanged: (val) => selectedSesi.value = val,
                  ),
                )),
              ),
              const SizedBox(height: 20),
              
              Obx(() {
                if (selectedSesi.value == null) return const Text("Daftar Mahasiswa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
                
                final pKe = selectedSesi.value!['pertemuan_ke'];
                final totalMahasiswa = controller.listMahasiswaKrs.length;
                final totalHadir = controller.listMahasiswaKrs.where((mhs) {
                  return controller.isMahasiswaHadir(mhs['nim'], pKe);
                }).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Daftar Mahasiswa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                );
              }),
              const SizedBox(height: 10),
              
              Expanded(
                child: Obx(() {
                  if (selectedSesi.value == null) {
                    return const Center(child: Text("Silakan pilih pertemuan terlebih dahulu."));
                  }
                  
                  final currentSesi = selectedSesi.value!;
                  final pKe = currentSesi['pertemuan_ke'];

                  return ListView.separated(
                    itemCount: controller.listMahasiswaKrs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final mhs = controller.listMahasiswaKrs[index];
                      final nimMhs = mhs['nim'];
                      
                      // Ambil status presensi (Hadir, Izin, Sakit, atau null jika belum)
                      final status = controller.getMahasiswaStatus(nimMhs, pKe);
                      final bool isHadir = status != null;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isHadir ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(
                            isHadir ? Icons.close : Icons.check,
                            color: isHadir ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(mhs['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(nimMhs ?? '-', style: const TextStyle(fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHadir ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status?.toUpperCase() ?? "Presence",
                            style: TextStyle(
                              color: isHadir ? Colors.red : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
      isScrollControlled: true,
    );
  }
}
