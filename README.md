# My Presence UMM - Aplikasi Presensi

---

## Struktur Proyek 


```
lib/
├── app_routes/          # Daftar alamat halaman
│   ├── app_pages.dart   # Menghubungkan alamat dengan tampilan halaman
│   └── app_routes.dart  # Daftar nama-nama halaman (konstanta)
├── models/              # "Box Data" buat DB (Format data dari database)
├── modules/             # Folder FITUR 
│   ├── home/            # Fitur Beranda (home)
│   │   ├── bindings/    # yg menghubungkan controller ke view
│   │   ├── controllers/ # Tempat nulis logika dan fungsi
│   │   └── views/       # Tempat desain tampilan UI
│   ├── login/           # Fitur Masuk Akun
│   ├── rekap_kehadiran/ # Fitur Riwayat Absensi
│   └── map_detail/      # Fitur Map & Titik Absensi
├── utils/               # buat warna, gaya tulisan, dll
└── main.dart            # Titik awal aplikasi dijalankan
```

---

## Penjelasan

1.  **Modules**: Jika ingin mengubah tampilan profil, carilah di folder fitur yang sesuai di bagian `views`. Jika ingin mengubah cara kerja fitur (logika), carilah di folder `controllers`.
2.  **Controller vs View**: 
    *   **View** : utnuk menampilkan gambar atau teks.
    *   **Controller** : untuk logic dibalik view, misal menghitung, dan mengambil data dari internet.
3.  **Bindings**: fungsinya menghubungkan controller dan view.
4.  **App Routes**: Agar kita tidak salah panggil nama halaman. Kita pakai nama panggilan yang tetap (konstanta) agar aman dari salah ketik.
5.  **Utils**: Kalau kita ingin ganti warna tema aplikasi (misal dari merah ke biru), kita cukup ubah satu baris di `AppColors.dart`, dan seluruh aplikasi akan berubah otomatis.

---

## TechStack
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [GetX](https://pub.dev/packages/get) (Untuk navigasi dan state)
- **Backend**: [Supabase](https://supabase.com/) (Database dan Akun User)
- **Maps**: [Flutter Map](https://pub.dev/packages/flutter_map) (Untuk peta)
- **Location**: [Geolocator](https://pub.dev/packages/geolocator) (Untuk GPS)

---

## 🚀 Cara Menjalankan Proyek

1. **Clone repository**.
2. **Install library** :
   ```bash
   flutter pub get
   ```
3. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

