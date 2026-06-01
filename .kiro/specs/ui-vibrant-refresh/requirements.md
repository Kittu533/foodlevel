# Requirements Document

## Introduction

Fitur **UI Vibrant Refresh** adalah polish menyeluruh untuk tampilan aplikasi FoodLevel dengan dua tujuan utama: (1) menghadirkan tema warna baru bernama **Vibrant Earth / Healthy Glow** yang colorful, fresh, dan relate sama vibe Gen Z Indonesia tanpa kehilangan nuansa "makanan sehat", dan (2) menambahkan lapisan animasi dan microinteraction biar app kerasa premium, playful, dan hidup di setiap layar (Scan, Result, History, Guide, Home).

Refresh ini bersifat _UI-only_ — gak ngubah arsitektur fitur, state management (Riverpod), atau alur bisnis yang udah ada. Widget shared yang sudah ada (`AnimatedEntry`, `PulseIconButton`, `SectionCard`, `SoftChip`, `FoodLevelBadge`) di-_refresh_ supaya kompatibel sama tema baru, bukan ditulis ulang dari nol. Aplikasi tetap harus mulus di Android mid-range (target 60fps) dan menghormati preferensi _reduced motion_ dari sistem.

## Glossary

- **App**: Aplikasi mobile FoodLevel berbasis Flutter (Material 3, Riverpod).
- **ThemeEngine**: Modul `lib/core/theme/app_theme.dart` yang nge-expose `ThemeData` light dan dark untuk seluruh app.
- **VibrantEarthPalette**: Set warna brand baru — Matcha Green (primary), Terracotta Orange (accent), Mustard Yellow (secondary), Cream Beige (surface), Deep Charcoal (text on light).
- **HomeScreen**: Layar root dengan bottom navigation 3 tab (Scan, Guide, History).
- **ScanScreen**: Layar capture/pick gambar makanan via kamera atau galeri.
- **ResultScreen**: Layar hasil prediksi nutrisi + Nutri Level (A–D).
- **HistoryScreen**: Layar daftar hasil scan tersimpan.
- **GuideScreen**: Layar panduan penggunaan & info Nutri Level.
- **BottomNav**: Komponen navigasi bawah (3 tab) di `HomeScreen`.
- **NutriLevelBadge**: Badge warna A/B/C/D yang nunjukin grade kesehatan makanan.
- **NutritionBar**: Visualisasi bar/ring untuk satu nilai nutrisi (kalori, protein, lemak, karbo, gula).
- **PredictionList**: Daftar kandidat prediksi makanan dengan confidence bar.
- **PageTransition**: Animasi transisi antar layar saat push/pop route.
- **HapticController**: Util tipis untuk men-trigger haptic feedback (`HapticFeedback.lightImpact`, `selectionClick`, dst).
- **MotionPreference**: Nilai boolean dari `MediaQuery.of(context).disableAnimations` yang menentukan apakah animasi non-esensial dimatikan.
- **AnimationBudget**: Set durasi standar yang dipakai konsisten — Fast (150ms), Base (300ms), Slow (500ms), Hero (450ms).
- **NutriLevel_A / B / C / D**: Empat tingkatan grade kesehatan makanan; A paling sehat, D paling kurang sehat.
- **ConfettiBurst**: Efek confetti 1.5 detik yang muncul saat hasil scan adalah `NutriLevel_A`.
- **ShimmerSkeleton**: Placeholder loading dengan efek gradien bergerak.
- **HeroFoodImage**: Hero widget gambar makanan yang dianimasikan dari thumbnail (Home/History) ke `ResultScreen`.

---

## Requirements

### Requirement 1: Tema Warna Vibrant Earth (Light)

**User Story:** Sebagai user Gen Z, gue mau app-nya keliatan colorful dan fresh tapi tetap related sama nuansa makanan sehat, biar enak dipandang dan beda dari app nutrisi lain yang biasa-biasa aja.

#### Acceptance Criteria

1. THE ThemeEngine SHALL menyediakan satu `ThemeData` light berbasis `ColorScheme.fromSeed` dengan `seedColor` Matcha Green `#2E7D5C` dan `brightness` `Brightness.light`.
2. THE ThemeEngine SHALL meng-override warna `secondary` ke Terracotta Orange `#E76F51` dan `tertiary` ke Mustard Yellow `#F4A261` di dalam `ColorScheme` light.
3. THE ThemeEngine SHALL menetapkan `scaffoldBackgroundColor` light ke Cream Beige `#FFF8EC`.
4. THE ThemeEngine SHALL menetapkan warna teks default `onSurface` light ke Deep Charcoal `#2D3142`.
5. THE ThemeEngine SHALL memastikan rasio kontras teks `onSurface` terhadap `surface` minimal 4.5:1 (WCAG AA untuk teks normal).
6. WHEN `AppBar`, `Card`, `FilledButton`, `OutlinedButton`, atau `NavigationBar` di-render, THE ThemeEngine SHALL memakai warna dari `VibrantEarthPalette` tanpa hardcoded color di luar `ThemeEngine`.

### Requirement 2: Tema Warna Vibrant Earth (Dark)

**User Story:** Sebagai user yang sering pake HP malam-malam, gue mau dark mode yang tetap colorful dan ga bikin mata sakit.

#### Acceptance Criteria

1. THE ThemeEngine SHALL menyediakan `ThemeData` dark berbasis `ColorScheme.fromSeed` dengan `seedColor` Matcha Green `#2E7D5C` dan `brightness` `Brightness.dark`.
2. THE ThemeEngine SHALL menetapkan `scaffoldBackgroundColor` dark ke Deep Charcoal varian `#1A1C22`.
3. THE ThemeEngine SHALL meng-override warna aksen dark — `secondary` `#FF8C42`, `tertiary` `#FFB627` — dengan saturasi yang disesuaikan untuk dark surface.
4. THE ThemeEngine SHALL memastikan rasio kontras teks `onSurface` dark terhadap `surface` dark minimal 4.5:1.
5. WHEN `MediaQuery.platformBrightnessOf(context)` bernilai `Brightness.dark`, THE App SHALL otomatis memakai `ThemeData` dark tanpa intervensi user.
6. THE App SHALL memakai `ThemeMode.system` sebagai default sehingga mengikuti preferensi sistem.

### Requirement 3: Palet Warna Nutri Level

**User Story:** Sebagai user, gue mau bisa langsung tahu makanan ini grade-nya berapa cuma dari warna badge-nya, dan warnanya kerasa modern bukan kayak rambu lalu lintas.

#### Acceptance Criteria

1. THE ThemeEngine SHALL menyediakan empat semantic color untuk Nutri Level: `levelA` `#4CAF50`, `levelB` `#A8C957`, `levelC` `#F4A261`, `levelD` `#E76F51`.
2. THE NutriLevelBadge SHALL memakai `levelA`, `levelB`, `levelC`, atau `levelD` sesuai grade yang diterima sebagai prop, tanpa hardcoded color di widget level.
3. THE ThemeEngine SHALL menyediakan varian `onLevelX` (warna teks/icon di atas badge) untuk masing-masing level dengan kontras minimal 4.5:1.
4. WHEN tema dark aktif, THE ThemeEngine SHALL menyesuaikan saturasi warna level supaya tetap kontras minimal 4.5:1 terhadap background dark.
5. WHERE grade adalah `NutriLevel_D`, THE NutriLevelBadge SHALL tetap memakai warna `levelD` `#E76F51` (terracotta) bukan merah harsh `#FF0000`, supaya tidak feel like a warning sign.

### Requirement 4: Animasi Scan Flow

**User Story:** Sebagai user, gue pengen pas lagi scan makanan tuh kerasa kayak app beneran nge-scan, bukan cuma tombol biasa, biar lebih engaging.

#### Acceptance Criteria

1. WHILE `ScanScreen` menampilkan preview gambar yang sedang diproses, THE ScanScreen SHALL menampilkan overlay scanning beam yang bergerak vertikal dari atas ke bawah secara loop dengan periode 1500ms.
2. WHILE `ScanScreen` sedang menunggu hasil prediksi (`isLoading == true`), THE ScanScreen SHALL menampilkan `ShimmerSkeleton` placeholder untuk area hasil prediksi, bukan `CircularProgressIndicator` polos.
3. WHEN user men-tap tombol kamera utama, THE ScanScreen SHALL menjalankan animasi scale tombol dari 1.0 ke 0.94 ke 1.0 dengan durasi 150ms (Fast).
4. WHEN user men-tap tombol kamera utama, THE HapticController SHALL men-trigger `HapticFeedback.mediumImpact` sekali.
5. IF kamera atau galeri gagal mengembalikan gambar (error/cancel oleh user), THEN THE ScanScreen SHALL menampilkan `SnackBar` dengan teks "Yah, gak jadi nih. Coba lagi ya 📸" dan TIDAK menjalankan animasi scanning beam.
6. WHEN proses scan selesai sukses, THE ScanScreen SHALL men-trigger `HapticFeedback.lightImpact` sekali sebelum navigasi ke `ResultScreen`.

### Requirement 5: Hero Transition Gambar Makanan

**User Story:** Sebagai user, gue mau gambar makanan yang gue scan ke-zoom mulus dari list/preview ke halaman result, biar transisinya kerasa smooth dan premium.

#### Acceptance Criteria

1. THE ScanScreen, HistoryScreen, dan ResultScreen SHALL membungkus gambar makanan utama dalam `Hero` widget dengan `tag` unik per scan (format: `food-image-{scanId}`).
2. WHEN navigasi push dari `ScanScreen` ke `ResultScreen` terjadi, THE PageTransition SHALL menjalankan Hero animation gambar selama 450ms (Hero) dengan curve `Curves.easeOutCubic`.
3. WHEN navigasi pop dari `ResultScreen` kembali ke layar sebelumnya, THE PageTransition SHALL menjalankan Hero animation reverse selama 450ms.
4. IF `MotionPreference` bernilai `true` (reduced motion aktif), THEN THE PageTransition SHALL memakai fade-only transition tanpa scale/translate selama 200ms.

### Requirement 6: Animasi Hasil Nutrisi

**User Story:** Sebagai user, gue mau pas hasil scan muncul tuh bar nutrisinya keisi pelan-pelan biar berasa "ta-da", bukan langsung jadi kayak teks biasa.

#### Acceptance Criteria

1. WHEN `ResultScreen` pertama kali ditampilkan, THE NutritionBar SHALL menganimasikan nilai dari 0 ke target value dengan durasi 800ms dan curve `Curves.easeOutCubic`.
2. WHEN `ResultScreen` pertama kali ditampilkan, THE NutritionBar SHALL menjalankan animasi secara staggered — bar berikutnya mulai 80ms setelah bar sebelumnya — untuk minimal 5 metrik nutrisi (kalori, protein, lemak, karbo, gula).
3. WHEN `NutriLevelBadge` muncul di `ResultScreen`, THE NutriLevelBadge SHALL menjalankan animasi reveal: `scale` dari 0.6 ke 1.0 dengan curve `Curves.elasticOut` selama 600ms, lalu glow ring dengan opacity dari 0 ke 0.4 ke 0 dalam 1200ms.
4. WHERE grade adalah `NutriLevel_D`, THE NutriLevelBadge SHALL menambahkan animasi shake horizontal (±4px) selama 400ms tepat setelah scale-in selesai.
5. WHERE grade adalah `NutriLevel_A`, THE ResultScreen SHALL memicu `ConfettiBurst` selama 1500ms tepat setelah `NutriLevelBadge` reveal selesai.
6. THE PredictionList SHALL menganimasikan `confidence bar` setiap item secara staggered (delay 60ms per item) dari width 0 ke width target dalam 500ms dengan curve `Curves.easeOutCubic`.
7. IF `MotionPreference` bernilai `true`, THEN THE NutritionBar, NutriLevelBadge, dan PredictionList SHALL menampilkan nilai final secara langsung tanpa animasi tween, dan THE ResultScreen SHALL TIDAK memicu `ConfettiBurst` maupun shake.

### Requirement 7: Bottom Navigation Interaktif

**User Story:** Sebagai user, gue mau pas pindah tab tuh ada feedback visual yang lucu dan kerasa hidup, bukan cuma color change.

#### Acceptance Criteria

1. WHEN user men-tap tab pada `BottomNav`, THE BottomNav SHALL menganimasikan indicator pill geser ke posisi tab baru dengan spring physics (`SpringSimulation` dengan `stiffness=180`, `damping=20`).
2. WHEN tab aktif berubah, THE BottomNav SHALL menganimasikan icon tab terpilih dengan scale dari 1.0 ke 1.15 ke 1.0 selama 250ms dan curve `Curves.easeOutBack`.
3. WHEN user men-tap tab `BottomNav`, THE HapticController SHALL men-trigger `HapticFeedback.selectionClick` sekali.
4. THE BottomNav SHALL memakai warna `primary` dari `VibrantEarthPalette` untuk indicator aktif dan `onSurfaceVariant` untuk icon non-aktif.
5. IF `MotionPreference` bernilai `true`, THEN THE BottomNav SHALL berpindah tab tanpa animasi spring/scale (instant indicator move).

### Requirement 8: Page Transition Custom

**User Story:** Sebagai user, gue mau perpindahan antar halaman tuh smooth dan ga jarring, biar app kerasa polished.

#### Acceptance Criteria

1. WHEN `Navigator.push` dipanggil dari layar manapun ke `ResultScreen`, `GuideScreen`, atau detail history, THE PageTransition SHALL memakai kombinasi fade (opacity 0→1) + slide (offset 24px vertikal → 0) dengan durasi 320ms.
2. WHEN `Navigator.pop` dipanggil, THE PageTransition SHALL memakai reverse fade + slide dengan durasi 240ms.
3. THE PageTransition SHALL memakai curve `Curves.easeOutCubic` untuk push dan `Curves.easeInCubic` untuk pop.
4. IF `MotionPreference` bernilai `true`, THEN THE PageTransition SHALL memakai fade-only dengan durasi 150ms tanpa slide offset.

### Requirement 9: Interaksi History Screen

**User Story:** Sebagai user, gue mau ngelola riwayat scan dengan gesture yang fun (swipe-to-delete, pull-to-refresh) dan dapat feedback visual yang jelas tiap aksi.

#### Acceptance Criteria

1. WHEN user men-swipe item di `HistoryScreen` ke kiri lebih dari 40% lebar item, THE HistoryScreen SHALL menampilkan background animasi merah-terracotta `#E76F51` dengan icon trash yang fade-in dari opacity 0 ke 1.
2. WHEN swipe melewati threshold 40% dan dilepas, THE HistoryScreen SHALL menghapus item dengan animasi collapse vertical (height 0) selama 300ms, lalu menampilkan `SnackBar` "Hasil scan dihapus" dengan tombol `UNDO` aktif selama 4 detik.
3. WHEN user men-tap `UNDO` pada SnackBar, THE HistoryScreen SHALL mengembalikan item ke posisi semula dengan animasi expand selama 300ms.
4. WHEN user men-pull `HistoryScreen` ke bawah lebih dari 80px, THE HistoryScreen SHALL menampilkan custom pull-to-refresh dengan icon makanan berputar (rotation 0→2π loop) selama proses refresh.
5. WHEN jumlah item history berubah, THE HistoryScreen SHALL menganimasikan label "X hasil tersimpan" dengan counter tween dari nilai lama ke nilai baru selama 400ms.
6. WHEN user men-tap filter chip (misal "Hari ini", "Level A"), THE filter chip SHALL menjalankan animasi scale-in checkmark icon dari 0 ke 1 selama 200ms dengan curve `Curves.easeOutBack`.
7. WHEN user men-tap filter chip, THE HapticController SHALL men-trigger `HapticFeedback.selectionClick` sekali.

### Requirement 10: Empty State & Celebrations

**User Story:** Sebagai user baru yang belum punya history, gue mau empty state-nya playful biar gue ga ngerasa app ini kosong dan boring.

#### Acceptance Criteria

1. WHEN `HistoryScreen` di-render dan list kosong, THE HistoryScreen SHALL menampilkan ilustrasi animasi (Lottie atau implicit animation kustom) dengan loop subtle (max 4s per loop) dan teks ajakan "Yuk scan makanan pertama lo!".
2. WHEN `ResultScreen` menampilkan grade `NutriLevel_A`, THE ResultScreen SHALL memicu `ConfettiBurst` partikel (minimal 30 partikel) dengan warna campuran dari `VibrantEarthPalette` selama 1500ms.
3. WHEN `ConfettiBurst` aktif, THE HapticController SHALL men-trigger `HapticFeedback.heavyImpact` sekali pada awal animasi.
4. THE empty state animation SHALL berhenti loop setelah 30 detik untuk menghemat baterai.
5. IF `MotionPreference` bernilai `true`, THEN THE empty state SHALL menampilkan ilustrasi statis (frame pertama Lottie) tanpa loop.

### Requirement 11: Microinteractions Konsisten

**User Story:** Sebagai user, gue mau tiap aksi penting di app kasih feedback haptic + visual yang konsisten, biar tiap tap kerasa "real".

#### Acceptance Criteria

1. WHEN user men-tap tombol `FilledButton` primer di layar manapun, THE HapticController SHALL men-trigger `HapticFeedback.lightImpact` sekali.
2. WHEN user men-tap `IconButton` action (save, share, delete), THE HapticController SHALL men-trigger `HapticFeedback.selectionClick` sekali.
3. WHEN user men-tap tombol simpan hasil scan, THE save button SHALL menjalankan animasi check icon morph dari icon `bookmark_outline` ke `bookmark_filled` selama 250ms.
4. WHERE platform adalah Android atau iOS, THE HapticController SHALL aktif sesuai aturan di atas.
5. WHERE platform adalah Web atau desktop, THE HapticController SHALL no-op (tidak memanggil `HapticFeedback`) tanpa melempar error.
6. THE app SHALL memakai `AnimationBudget` standar — Fast (150ms), Base (300ms), Slow (500ms), Hero (450ms) — untuk semua animasi UI baru.

### Requirement 12: Kompatibilitas Widget Shared yang Ada

**User Story:** Sebagai developer, gue mau widget shared yang udah dipake (`AnimatedEntry`, `PulseIconButton`, `SectionCard`, `SoftChip`, `FoodLevelBadge`) tetap bisa dipake setelah refresh, ga perlu rewrite massal di semua call site.

#### Acceptance Criteria

1. THE shared widgets `AnimatedEntry`, `PulseIconButton`, `SectionCard`, `SoftChip`, `FoodLevelBadge` SHALL mempertahankan public API (constructor params + named arguments) yang sama setelah refresh.
2. THE shared widgets di atas SHALL membaca warna dari `Theme.of(context).colorScheme` atau `VibrantEarthPalette` extension, bukan hardcoded color.
3. WHEN `SoftChip` menerima `color` prop opsional, THE SoftChip SHALL memakai warna tersebut; otherwise THE SoftChip SHALL fallback ke `colorScheme.primary` dari `VibrantEarthPalette`.
4. THE PulseIconButton SHALL mempertahankan animasi pulse existing tetapi memakai warna dari tema baru.
5. THE FoodLevelBadge SHALL memakai semantic color level (`levelA`, `levelB`, `levelC`, `levelD`) dari Requirement 3 alih-alih warna hardcoded.

### Requirement 13: Reduced Motion & Aksesibilitas

**User Story:** Sebagai user yang sensitif sama animasi atau pake setting accessibility, gue mau bisa matiin animasi tanpa kehilangan fungsionalitas app.

#### Acceptance Criteria

1. THE App SHALL membaca `MediaQuery.of(context).disableAnimations` sebagai sumber utama nilai `MotionPreference`.
2. IF `MotionPreference` bernilai `true`, THEN THE App SHALL menonaktifkan: scanning beam loop, shimmer skeleton movement, hero transition scale/translate, nutrition bar tween, badge scale-in, badge shake, confetti, bottom nav spring, dan empty state Lottie loop.
3. IF `MotionPreference` bernilai `true`, THEN THE App SHALL TETAP menampilkan state akhir (target value, posisi akhir, warna final) dari setiap elemen UI sehingga tidak ada konten yang hilang.
4. THE App SHALL mempertahankan haptic feedback walaupun `MotionPreference` `true` (haptic adalah feedback non-visual dan tidak dianggap motion).
5. THE App SHALL memastikan semua icon-only button memiliki `Semantics.label` dalam Bahasa Indonesia (contoh: "Hapus hasil scan", "Simpan ke history").
6. THE App SHALL memastikan kontras teks pada semua badge level (A–D) minimal 4.5:1 di mode light maupun dark.

### Requirement 14: Performa Animasi

**User Story:** Sebagai user yang pake Android mid-range, gue mau animasinya tetap smooth ga lag walau HP gue bukan flagship.

#### Acceptance Criteria

1. THE App SHALL menjalankan semua animasi UI pada 60fps target frame rate di device referensi mid-range (RAM 4GB, Snapdragon kelas 600 atau setara).
2. THE App SHALL TIDAK menjalankan lebih dari 3 animasi loop berkelanjutan (continuous, non-tap-triggered) secara bersamaan di satu layar.
3. WHEN sebuah layar di-pop dari navigator, THE App SHALL menghentikan dan men-dispose semua `AnimationController` di layar tersebut dalam method `dispose()`.
4. WHILE app berada di background (`AppLifecycleState.paused`), THE App SHALL menghentikan semua animasi loop (scanning beam, shimmer, empty state Lottie) dan melanjutkannya saat kembali ke `AppLifecycleState.resumed`.
5. THE shimmer skeleton SHALL memakai `RepaintBoundary` di sekeliling area shimmer untuk membatasi repaint scope.

### Requirement 15: Tech Stack Tambahan

**User Story:** Sebagai developer, gue mau library animasi yang dipake well-maintained dan ga blow-up size APK terlalu banyak.

#### Acceptance Criteria

1. THE pubspec.yaml SHALL menambahkan dependency `flutter_animate` (versi stable terbaru) sebagai library utama untuk declarative animations.
2. THE pubspec.yaml SHALL menambahkan dependency `shimmer` (versi stable terbaru) untuk skeleton loading.
3. WHERE empty state animation memerlukan ilustrasi vector, THE pubspec.yaml SHALL menambahkan dependency `lottie` (versi stable terbaru) sebagai opsional dan asset Lottie disimpan di `assets/animations/`.
4. WHERE celebration untuk `NutriLevel_A` diimplementasikan, THE pubspec.yaml SHALL menambahkan dependency `confetti` (versi stable terbaru) sebagai opsional.
5. WHERE staggered animations untuk list diperlukan, THE pubspec.yaml MAY menambahkan `flutter_staggered_animations` sebagai opsional jika `flutter_animate` belum mencukupi.
6. THE App SHALL TIDAK menambah dependency native (yang memerlukan setup `android/` atau `ios/`) selain yang sudah ada di project saat ini.

### Requirement 16: Bahasa & Tone UI

**User Story:** Sebagai user Gen Z Indonesia, gue mau copy di app-nya kerasa santai dan relate, bukan formal kaku.

#### Acceptance Criteria

1. THE App SHALL memakai Bahasa Indonesia santai untuk semua teks UI baru yang ditambah/diubah dalam fitur ini (contoh: "Yuk scan makanan!", "Hasil scan dihapus", "Yah, gak jadi nih").
2. THE App SHALL TIDAK memakai bahasa formal kaku seperti "Silakan melakukan pemindaian" atau "Mohon maaf, terjadi kesalahan".
3. THE App SHALL konsisten memakai sapaan informal ("lo/gue" atau "kamu") dalam satu sesi UX — fitur ini memilih "lo" sebagai default sapaan.
4. THE App SHALL memakai emoji secukupnya (maksimal 1 emoji per kalimat copy) untuk memperkuat tone playful tanpa berlebihan.
