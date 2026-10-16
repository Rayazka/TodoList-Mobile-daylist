# Daylist

Aplikasi Flutter dengan dua halaman: Home dan Kalender & Riwayat.

## Menjalankan

```sh
flutter pub get
flutter run
```

## Verifikasi dan build

```sh
flutter analyze
flutter test
flutter build apk --debug
```

## Struktur kode

- `lib/models`: model Todo immutable dan serialisasi JSON.
- `lib/data`: kontrak repository dan penyimpanan shared_preferences.
- `lib/controllers`: state bersama, sorting, toggle dan antrean simpan.
- `lib/pages`: Home serta Kalender & Riwayat.
- `lib/widgets`: form dan tampilan tugas yang dipakai ulang.
- `lib/theme`: warna dan tema Material 3.

Semua fungsi bernama diberi dokumentasi. Data awal kosong; tugas disimpan lokal di perangkat. Tanpa akun, backend, atau notifikasi. Deadline adalah tanggal lokal tanpa jam. Kalender menampilkan tugas pada tanggal deadline; Riwayat menampilkan semua tugas selesai termasuk yang tanpa deadline. Checkbox bisa dibatalkan dari kedua halaman.

Sorting berputar: terbaru → deadline terdekat → deadline terjauh. Tugas selesai selalu berada di bawah tugas aktif, tanpa deadline di akhir masing-masing kelompok saat sorting deadline. Error baca memblokir perubahan agar data lama tidak tertimpa; error tulis menyediakan tombol coba lagi.

Jika Gradle Windows melaporkan `Unable to establish loopback connection`, jalankan `./build_android.ps1`. Script membatasi direktori temporary Java ke folder build proyek dan memulihkan environment setelah selesai.
