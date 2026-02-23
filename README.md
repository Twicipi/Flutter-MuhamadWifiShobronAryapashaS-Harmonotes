# 🎵 Harmonotes - Song Journal

**Harmonotes** adalah aplikasi jurnal musik personal yang membantu musisi dan penulis lagu mencatat ide lagu, lirik, chord, dan mood kapan saja inspirasi datang. Dibangun dengan Flutter & Firebase untuk pengalaman seamless di Android.

---

## 🌟 Fitur Utama

### ✍️ Manajemen Lagu
- **CRUD lengkap**: Tambah, edit, hapus, dan lihat lagu beserta lirik & chord
- **Kategorisasi mood**: Filter lagu berdasarkan mood (Happy, Sad, Chill, Focus)
- **Pencarian cerdas**: Cari lagu berdasarkan judul atau artis
- **Real-time sync**: Data tersimpan otomatis ke Firebase Firestore

### 🔔 Sistem Notifikasi Pintar
- **Achievement**: Notifikasi otomatis setiap menyelesaikan 3 lagu ("Mantap! 🎶 Kamu sudah menyelesaikan 3 lagu!")
- **Daily Motivation**: Pesan inspirasi harian saat buka app pertama kali ("Hai! Ada ide lagu yang ingin diabadikan hari ini? 🎵")
- **Inactivity Reminder**: Pengingat jika >1 jam tidak menulis lagu ("Sudah lama sejak lagu terakhir. Ada ide baru? ✨")
- **Tanpa background task**: Notifikasi di-trigger saat buka app (hemat baterai, 100% reliable)

### 🔐 Autentikasi Aman
- Login dengan Email/Password
- Login cepat dengan Google Sign-In
- Persistent login (tidak perlu login ulang setelah force close)
- Proteksi data per-user di Firestore

### 🎨 UI/UX Modern
- Desain Material 3 dengan warna khas Harmonotes (`#667eea`)
- Pull-to-refresh native (swipe down untuk refresh data)
- Animasi halus dan responsif di semua device
- Dark mode friendly (mengikuti sistem)

---

## 📱 Screenshots

| Login | Home | Add Song | Detail Lagu |
|-------|------|----------|-------------|
| ![Login](assets/images/login.png) | ![Home](assets/images/home.png) | ![Add](assets/images/add_song.png) | ![Detail](assets/images/detail.png) |
| *Halaman login dengan Google/email* | *Daftar lagu dengan filter mood* | *Form tambah/edit lagu* | *Detail lengkap lagu* |

*(Ganti placeholder di atas dengan screenshot aktual dari aplikasimu)*

---

## ⚙️ Teknologi yang Digunakan

### Frontend (Flutter)
| Library | Versi | Kegunaan |
|---------|-------|----------|
| `provider` | ^6.1.5+1 | State management (MVVM pattern) |
| `firebase_core` | ^3.15.0 | Inisialisasi Firebase |
| `firebase_auth` | ^5.7.0 | Autentikasi user |
| `cloud_firestore` | ^5.6.0 | Database real-time (CRUD lagu) |
| `google_sign_in` | ^6.2.1 | Integrasi Google Sign-In |
| `flutter_local_notifications` | ^17.1.0 | Notifikasi lokal (achievement, daily, inactivity) |
| `permission_handler` | ^11.3.0 | Request izin notifikasi |
| `shared_preferences` | ^2.2.2 | Simpan timestamp untuk notifikasi harian/inactivity |

### Backend (Firebase)
- **Authentication**: Email/Password + Google Sign-In
- **Firestore Database**: 
  - Collection `users` (data profil)
  - Collection `songs` (data lagu per-user dengan subcollection)
- **Security Rules**: Proteksi data per-user (hanya pemilik yang bisa akses)

### Arsitektur
1. lib/
├── models/ # Data models (Song, User)
├── providers/ # Business logic (AuthProvider, SongProvider)
├── services/ # Firebase & notification services
├── widgets/ # Reusable UI components (MoodChip, SongCard)
└── pages/ # Screen utama (Home, Login, Add/Edit)

## 🚀 Cara Menjalankan Aplikasi

### Prasyarat
- Flutter SDK 3.10+
- Android Studio / VS Code
- Akun Firebase dengan project aktif

### Setup
1. **Clone repository:**
git clone https://github.com/username/harmonotes.git
cd harmonotes
2. **Setup Firebase:**
- Buat project di Firebase Console
- Download google-services.json untuk Android
- Letakkan di android/app/google-services.json
3. **Install dependencies:**
  flutter pub get
4. Jalankan di emulator/device:
  flutter run
### Build APK Release
  1. flutter clean
  2. flutter pub get
  3. flutter build apk --release

  APK hasil build:
  - build/app/outputs/flutter-apk/app-release.apk
  APK DOWNLOAD : https://drive.google.com/file/d/18UcD6BYtvIMD6P0-IodvTSEhvSS4_2QE/view?usp=sharing
