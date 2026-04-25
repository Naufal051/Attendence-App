import '../controllers/map_detail_controller.dart'; // Updated relative import
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../utils/AppColors.dart';

class MapDetailView extends StatefulWidget {
  final Map<String, dynamic> mataKuliahData;
  final String nimMahasiswa;

  const MapDetailView({Key? key, required this.mataKuliahData, required this.nimMahasiswa}) : super(key: key);

  @override
  State<MapDetailView> createState() => _MapDetailViewState();
}

class _MapDetailViewState extends State<MapDetailView> {
  final MapDetailController controller = Get.put(MapDetailController());

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final targetLatLng = LatLng(
        widget.mataKuliahData['latitude'] as double,
        widget.mataKuliahData['longitude'] as double
    );
    controller.fetchLocation(
        targetLatLng,
        widget.mataKuliahData['id'],
        widget.nimMahasiswa
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetLatLng = LatLng(
        widget.mataKuliahData['latitude'] as double,
        widget.mataKuliahData['longitude'] as double
    );
    final String namaMk = widget.mataKuliahData['nama_mk'] ?? 'Mata Kuliah';
    final String ruang = widget.mataKuliahData['ruang'] ?? '-';
    final String jam = "${widget.mataKuliahData['jam_mulai'] ?? '--'} - ${widget.mataKuliahData['jam_selesai'] ?? '--'}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Lokasi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
            icon: controller.isLoadingLocation.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh),
            tooltip: 'Perbarui Lokasi',
            onPressed: controller.isLoadingLocation.value ? null : () => _refreshData(),
          )),
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoadingLocation.value && controller.myLocation.value == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return FlutterMap(
              options: MapOptions(
                initialCenter: targetLatLng,
                initialZoom: 17.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.attendance.app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: targetLatLng,
                      color: AppColors.primary.withOpacity(0.15),
                      borderStrokeWidth: 2,
                      borderColor: AppColors.primary,
                      radius: controller.maxRadius.toDouble(),
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
                if (controller.myLocation.value != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [targetLatLng, controller.myLocation.value!],
                        strokeWidth: 3,
                        color: AppColors.primary.withOpacity(0.5),
                      )
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: targetLatLng,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.business, color: AppColors.primary, size: 40),
                    ),
                    if (controller.myLocation.value != null)
                      Marker(
                        point: controller.myLocation.value!,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 35),
                      ),
                  ],
                ),
              ],
            );
          }),

          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(() {
              final bool inRadius = controller.distanceInMeters.value <= controller.maxRadius;
              final bool alreadyAttended = controller.isAlreadyAttended.value;
              Color buttonColor = alreadyAttended ? AppColors.success : (inRadius ? AppColors.primary : Colors.grey.shade400);

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, -5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(namaMk, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        Text("${controller.distanceInMeters.value}m", style: TextStyle(color: inRadius ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [const Icon(Icons.access_time, size: 18), Text(jam, style: const TextStyle(fontSize: 12))]),
                        Column(children: [const Icon(Icons.room, size: 18), Text(ruang, style: const TextStyle(fontSize: 12))]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (controller.isLoadingLocation.value || controller.isSubmitting.value || !inRadius || alreadyAttended)
                            ? null
                            : () => controller.prosesPresensi(widget.mataKuliahData, widget.nimMahasiswa),
                        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                        icon: Icon(alreadyAttended ? Icons.check_circle : Icons.fingerprint, color: Colors.white),
                        label: Text(alreadyAttended ? "Sudah Absen" : (inRadius ? "LAKUKAN PRESENSI" : "DI LUAR RADIUS")),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
