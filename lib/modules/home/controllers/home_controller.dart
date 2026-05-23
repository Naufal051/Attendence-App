import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../utils/SharedPrefs.dart';

class HomeController extends GetxController {
  // Variabel Profil
  var role = "mahasiswa".obs;
  var namaMhs = "".obs;
  var prodi = "".obs;
  var nim = "".obs;
  var fotoUrl = "".obs;
  var email = "".obs;
  var fakultas = "".obs;

  // Variabel Lokasi
  var lokasiSaatini = "Mencari lokasi...".obs;

  // Variabel Jadwal
  var listJadwal = <dynamic>[].obs; 
  var jadwalHariIni = <dynamic>[].obs; // Menambahkan kembali variabel ini agar View tidak error
  var jadwalTerdekat = Rxn<dynamic>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    final savedData = SharedPrefs.getUserData();
    final args = Get.arguments ?? savedData;

    if (args != null) {
      role.value = args['role'] ?? 'mahasiswa';
      namaMhs.value = args['nama'] ?? '';
      prodi.value = args['prodi'] ?? '';

      if (role.value == 'mahasiswa') {
        nim.value = args['nim'] ?? '';
        _generateFotoUrl();
      } else {
        email.value = args['email'] ?? '-';
        fakultas.value = args['fakultas'] ?? '-';
        nim.value = args['nim']?.toString() ?? '';
      }
    }
    _fetchJadwalDariSupabase();
    _setupRealtimeListener();
    _dapatkanLokasi();
  }

  void _generateFotoUrl() {
    if (nim.value.length >= 4) {
      String folder = nim.value.substring(0, 4);
      fotoUrl.value = "https://krs.umm.ac.id/Poto/$folder/${nim.value}.JPG";
    }
  }

  Future<void> _dapatkanLokasi() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        lokasiSaatini.value = "${place.subLocality ?? ''}, ${place.locality ?? ''}";
      }
    } catch (e) {
      lokasiSaatini.value = "Lokasi tidak terdeteksi";
    }
  }

  void _setupRealtimeListener() {
    supabase
        .channel('public:mata_kuliah')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mata_kuliah',
          callback: (payload) => _fetchJadwalDariSupabase(),
        )
        .subscribe();
  }

  Future<void> _fetchJadwalDariSupabase() async {
    try {
      isLoading.value = true;
      debugPrint('Fetching jadwal untuk NIM: ${nim.value} dengan role: ${role.value}');
      
      var query = supabase.from('mata_kuliah').select('''
            id,
            nama_mk,
            sks,
            hari,
            jam_mulai,
            jam_selesai,
            ruang,
            latitude,
            longitude,
            radius_meter,
            dosen:dosen_id (nama)
          ''');

      // Jika role mahasiswa, filter berdasarkan KRS
      if (role.value == 'mahasiswa') {
        final krsResponse = await supabase
            .from('krs')
            .select('mk_id')
            .eq('nim', nim.value);
            
        debugPrint('KRS Response untuk ${nim.value}: $krsResponse');

        if (krsResponse != null && krsResponse.isNotEmpty) {
          final List<String> mkIds = krsResponse.map((e) => e['mk_id'].toString()).toList();
          query = query.filter('id', 'in', mkIds);
        } else {
          debugPrint('Peringatan: Mahasiswa ini tidak memiliki data di tabel KRS.');
          listJadwal.clear();
          jadwalHariIni.clear();
          jadwalTerdekat.value = null;
          return;
        }
      } 
      // Jika role dosen, filter berdasarkan dosen_id (NIM di sini dianggap ID Dosen)
      else if (role.value == 'dosen') {
        query = query.eq('dosen_id', nim.value);
      }

      final response = await query;
      debugPrint('Mata Kuliah Response: $response');

      if (response != null && response is List && response.isNotEmpty) {
        final data = response as List<dynamic>;
        listJadwal.assignAll(data);
        
        final String hariIni = _getHariIni();
        final filteredByDay = data.where((mk) {
          final mkHari = mk['hari']?.toString().toLowerCase() ?? '';
          return mkHari == hariIni.toLowerCase();
        }).toList();
        
        filteredByDay.sort((a, b) => (a['jam_mulai'] ?? '').compareTo(b['jam_mulai'] ?? ''));
        jadwalHariIni.assignAll(filteredByDay);
        
        _hitungJadwalTerdekat();
      } else {
        listJadwal.clear();
        jadwalHariIni.clear();
        jadwalTerdekat.value = null;
      }
    } catch (e) {
      debugPrint('Error fetch Supabase detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getHariIni() {
    switch (DateTime.now().weekday) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  void _hitungJadwalTerdekat() {
    if (listJadwal.isEmpty) {
      jadwalTerdekat.value = null;
      return;
    }

    final sekarang = DateTime.now();
    final formatWaktuSekarang = "${sekarang.hour.toString().padLeft(2, '0')}:${sekarang.minute.toString().padLeft(2, '0')}:00";

    try {
      List<dynamic> sorted = List.from(listJadwal);
      sorted.sort((a, b) => a['jam_mulai'].compareTo(b['jam_mulai']));
      
      jadwalTerdekat.value = sorted.firstWhere(
        (jk) => jk['jam_selesai'].toString().compareTo(formatWaktuSekarang) >= 0,
        orElse: () => null,
      );
    } catch (e) {
      jadwalTerdekat.value = null;
    }
  }
}
