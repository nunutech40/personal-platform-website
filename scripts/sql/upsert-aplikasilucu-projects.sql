-- Upsert recruiter-ready portfolio copy untuk 3 project AplikasiLucu.
--
-- Ketiga project ini adalah project eksplorasi teknologi Flutter:
--   - VoiceChanger  → https://github.com/nunutech40/VoiceChanger
--   - AuraApp       → https://github.com/nunutech40/AuraApp
--   - LiquidGlassTabs → https://github.com/nunutech40/flutter-liquidglass-bottomsheet
--
-- Masing-masing mengeksplorasi satu area teknis yang berbeda:
--   VoiceChanger  → Dart FFI + C++ SoLoud DSP engine + Dart Isolate
--   AuraApp       → Flutter MethodChannel + Swift Native + Apple Vision Framework
--   LiquidGlassTabs → Custom Flutter widget (BackdropFilter + CustomPainter + AnimatedPositioned)
--
-- Usage from repository root:
--   /opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-aplikasilucu-projects.sql

-- =====================================================================================
-- 1) VoiceChanger — Flutter + Dart FFI + C++ SoLoud DSP Engine
-- =====================================================================================
INSERT INTO projects (
  id,
  title,
  slug,
  summary,
  description,
  problem,
  solution,
  result,
  role,
  tech_stack,
  year,
  status,
  featured,
  project_type,
  platforms,
  disciplines,
  ownership,
  team_size,
  duration,
  impact_summary,
  technical_highlights,
  architecture_notes,
  tradeoffs,
  metrics,
  demo_url,
  demo_video_url,
  github_url,
  case_study_visibility,
  sort_order,
  sort_date,
  inserted_at,
  updated_at
) VALUES (
  'c3333333-4444-5555-8666-777700000001',
  'VoiceChanger — Flutter + Dart FFI + C++ SoLoud DSP Engine',
  'voicechanger-flutter-dart-ffi-soloud',
  $$Flutter voice changer yang mengintegrasikan C++ SoLoud audio engine via Dart FFI (bukan MethodChannel) untuk manipulasi pitch dan tempo zero-latency, dengan Clean Architecture dan Dart Isolate untuk visualizer.$$,
  $$VoiceChanger adalah project eksplorasi Flutter yang membuktikan bahwa UI cross-platform Dart bisa melakukan direct memory manipulation ke biner C++ native untuk mencapai pemrosesan sinyal digital (DSP) sekelas aplikasi native, tanpa overhead asynchronous MethodChannel. Pengguna merekam suara, memilih template preset (Normal, Chipmunk, Monster), dan slider pitch/tempo langsung mengubah parameter di memory C++ secara synchronous.$$,
  $$Manipulasi audio real-time di Flutter biasanya memakai MethodChannel yang bersifat asynchronous dan melewati OS message queue. Untuk DSP, delay 15 milidetik saja sudah merusak pengalaman karena suara terasa lag saat slider digeser. Selain itu, visualizer gelombang suara yang berjalan di Main Thread akan menyebabkan frame drop karena beban kalkulasi animasi bersaing dengan rendering UI.$$,
  $$Mengintegrasikan flutter_soloud yang membungkus C++ SoLoud engine via Dart FFI. Saat slider pitch digeser, Dart langsung menimpa pointer float di memory C++ secara synchronous, melewati OS queue sepenuhnya. SoLoud membaca perubahan di Audio Thread terpisah dan mengubah nada secara instan.

Visualizer gelombang suara dijalankan di Dart Isolate terpisah agar Main Thread tidak drop di bawah 60fps. Clean Architecture diterapkan dengan tiga lapisan: Data (AudioNativeDataSource memanggil flutter_soloud, file picker, dan history), Domain (AudioFilterEntity, UseCases, Repository contract), dan Presentation (VoiceTunerCubit dan AuraVoiceCubit via BLoC/Cubit).$$,
  ARRAY[
    'Manipulasi pitch dan tempo real-time via Dart FFI ke C++ SoLoud engine tanpa latency yang terasa.',
    'Template preset (Normal, Chipmunk, Monster) mengubah parameter DSP secara instan saat dipilih.',
    'Dart Isolate untuk fake visualizer animasi agar Main Thread tetap smooth di 60fps.',
    'Clean Architecture tiga lapisan dengan UseCase untuk record, import file, dan history.',
    'Redesign plan Cupertino light mode terdokumentasi untuk iterasi UI berikutnya.'
  ],
  'Solo Flutter developer (eksplorasi teknologi)',
  ARRAY[
    'Flutter',
    'Dart',
    'Dart FFI',
    'flutter_soloud (C++ SoLoud engine)',
    'flutter_bloc (BLoC + Cubit)',
    'get_it',
    'equatable',
    'record',
    'file_picker',
    'permission_handler',
    'Dart Isolate'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['flutter'],
  ARRAY['flutter_developer'],
  'Solo builder: integrasi Dart FFI ke C++ SoLoud, Clean Architecture, BLoC/Cubit, Dart Isolate untuk visualizer, dan dokumentasi DSP engine architecture.',
  'Solo project',
  '2026',
  $$Menunjukkan pemahaman batas antara Dart runtime dan C++ native memory, cara kerja Dart FFI sebagai alternatif MethodChannel untuk kasus latency-sensitive, dan bagaimana Dart Isolate dipakai untuk memindahkan beban komputasi dari Main Thread.$$,
  ARRAY[
    'Dart FFI dipakai alih-alih MethodChannel: Dart langsung menimpa pointer float di memory C++ secara synchronous, mengeliminasi overhead OS message queue.',
    'SoLoud DSP pipeline: file audio di-decode ke PCM buffer C++, lalu pitch shifting (resampling + time-stretch) dan reverb (convolution) dijalankan on-the-fly sebelum dikirim ke OS Audio API (CoreAudio/OpenSL ES).',
    'Dart Isolate untuk fake visualizer: kalkulasi animasi gelombang suara dijalankan di thread terpisah agar Main Thread tidak drop frame.',
    'Clean Architecture: AudioNativeDataSource sebagai satu-satunya titik kontak ke flutter_soloud dan file system, UseCase sebagai orkestrator per aksi (apply filter, get history, pick file), Cubit sebagai state manager di Presentation.',
    'Satu binary tunggal: C++ SoLoud dikompilasi via CMake (Android) dan CocoaPods/Clang (iOS) menjadi shared library yang di-link ke Flutter engine, bukan server terpisah.'
  ],
  $$Tiga lapisan Clean Architecture: Data (AudioNativeDataSource memanggil flutter_soloud, file_picker, dan local directory), Domain (AudioFilterEntity, IAudioRepository, tiga UseCase), dan Presentation (VoiceTunerCubit untuk slider state, AuraVoiceCubit untuk playback state). Cubit tidak tahu tentang dart:io atau file_picker secara langsung; mereka hanya memanggil UseCase yang di-inject via GetIt.

Saat runtime, Dart dan C++ hidup di dua ruang memory berbeda dalam satu binary: Dart memakai Garbage Collector, C++ memakai manual malloc/free. FFI menjadi jembatan synchronous yang memungkinkan Dart menulis langsung ke pointer C++ tanpa melewati OS queue.$$,
  $$Memilih Dart FFI alih-alih MethodChannel untuk audio karena MethodChannel asynchronous dan melewati OS message queue, yang menambah latency tidak terduga untuk kasus DSP real-time. Konsekuensinya setup FFI lebih kompleks dan butuh pemahaman pointer management. Export audio ke file baru (re-encoding) ditunda ke v2 karena membutuhkan ffmpeg_kit_flutter yang menambah kompleksitas build iOS; MVP fokus pada demonstrasi DSP pipeline dulu. Live monitoring (efek real-time saat merekam) juga ditunda karena routing audio dua arah rentan feedback loop di hardware Android yang terfragmentasi.$$,
  ARRAY[
    'DSP pipeline: decode PCM → pitch shift (resampling + time-stretch) → reverb (convolution) → OS Audio API → speaker.',
    'Public proof: repo publik di GitHub dengan dokumentasi DSP_ENGINE_ARCHITECTURE.md.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/VoiceChanger',
  'public',
  3,
  DATE '2026-05-09',
  NOW(),
  NOW()
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  description = EXCLUDED.description,
  problem = EXCLUDED.problem,
  solution = EXCLUDED.solution,
  result = EXCLUDED.result,
  role = EXCLUDED.role,
  tech_stack = EXCLUDED.tech_stack,
  year = EXCLUDED.year,
  status = EXCLUDED.status,
  featured = EXCLUDED.featured,
  project_type = EXCLUDED.project_type,
  platforms = EXCLUDED.platforms,
  disciplines = EXCLUDED.disciplines,
  ownership = EXCLUDED.ownership,
  team_size = EXCLUDED.team_size,
  duration = EXCLUDED.duration,
  impact_summary = EXCLUDED.impact_summary,
  technical_highlights = EXCLUDED.technical_highlights,
  architecture_notes = EXCLUDED.architecture_notes,
  tradeoffs = EXCLUDED.tradeoffs,
  metrics = EXCLUDED.metrics,
  demo_url = EXCLUDED.demo_url,
  demo_video_url = EXCLUDED.demo_video_url,
  github_url = EXCLUDED.github_url,
  case_study_visibility = EXCLUDED.case_study_visibility,
  sort_order = EXCLUDED.sort_order,
  sort_date = EXCLUDED.sort_date,
  updated_at = NOW();

-- =====================================================================================
-- 2) AuraApp — Flutter + Swift Native MethodChannel + Apple Vision Framework
-- =====================================================================================
INSERT INTO projects (
  id,
  title,
  slug,
  summary,
  description,
  problem,
  solution,
  result,
  role,
  tech_stack,
  year,
  status,
  featured,
  project_type,
  platforms,
  disciplines,
  ownership,
  team_size,
  duration,
  impact_summary,
  technical_highlights,
  architecture_notes,
  tradeoffs,
  metrics,
  demo_url,
  demo_video_url,
  github_url,
  case_study_visibility,
  sort_order,
  sort_date,
  inserted_at,
  updated_at
) VALUES (
  'c3333333-4444-5555-8666-777700000002',
  'AuraApp — Flutter + Swift Native + Apple Vision Framework',
  'auraapp-flutter-swift-native-apple-vision',
  $$iOS app Flutter yang menjembatani UI Dart ke Swift native via MethodChannel untuk menjalankan Apple Vision Framework (face landmark detection) dan kalkulasi Golden Ratio secara offline, dengan Clean Architecture dan animasi glassmorphism.$$,
  $$AuraApp adalah project eksplorasi Flutter yang membuktikan decoupled architecture antara Flutter UI dan native iOS computation. Aplikasi memilih banyak foto dari galeri, mengirim path ke Swift via MethodChannel, lalu Swift menjalankan VNDetectFaceLandmarksRequest dari Apple Vision Framework untuk memetakan koordinat wajah dan menghitung skor berdasarkan Golden Ratio (Phi = 1.618). Hasilnya dikembalikan ke Flutter sebagai leaderboard.$$,
  $$Eksplorasi Flutter-to-Native bridging yang jujur membutuhkan kasus nyata di mana native computation tidak bisa digantikan oleh Dart. Apple Vision Framework (VNDetectFaceLandmarksRequest) adalah contoh ideal: face landmark detection berjalan di Neural Engine iPhone secara offline, tidak ada Dart library yang setara, dan hasilnya harus dikembalikan ke Flutter UI untuk dirender. Ini memaksa pemahaman MethodChannel, serialisasi data lintas bahasa, dan Clean Architecture yang memisahkan bridge dari business logic.$$,
  $$Membangun iOS app Flutter dengan Clean Architecture tiga lapisan. Di sisi Swift (AppDelegate.swift), MethodChannel menangkap request, mengkonversi path ke UIImage, menjalankan VNDetectFaceLandmarksRequest, mengekstrak koordinat wajah (mata, bibir, hidung, kontur), menghitung Euclidean distance antar titik, membandingkan rasio dengan Phi (1.618), dan mengembalikan array Dictionary ke Flutter.

Di sisi Flutter, NativeAuraDataSource memanggil MethodChannel.invokeMethod(), AuraModel mem-parse Map dari Swift ke entity Dart, AuraRepositoryImpl mengkonversi model ke AuraEntity, CalculateAuraUseCase mengorkestrasikan eksekusi, dan AuraCubit mengelola state (Initial, Scanning, Success, Error). UI menampilkan animasi laser scanner saat Scanning dan glassmorphism leaderboard card saat Success.$$,
  ARRAY[
    'Face landmark detection offline via Apple Vision Framework (VNDetectFaceLandmarksRequest) di Neural Engine iPhone.',
    'Golden Ratio scoring: Euclidean distance antar titik wajah dibandingkan dengan Phi (1.618) untuk menghasilkan skor 0-100.',
    'Clean Architecture dengan MethodChannel sebagai satu-satunya titik kontak ke native iOS, terisolasi di Data layer.',
    'Animasi laser scanner (CustomPaint + AnimationController) dan glassmorphism leaderboard card (BackdropFilter).',
    'Satu binary iOS: Swift dan Flutter dikompilasi bersama, MethodChannel berkomunikasi via internal RAM bukan network.'
  ],
  'Solo Flutter developer (eksplorasi teknologi)',
  ARRAY[
    'Flutter',
    'Dart',
    'Swift',
    'Apple Vision Framework (VNDetectFaceLandmarksRequest)',
    'MethodChannel (FlutterMethodChannel)',
    'flutter_bloc (BLoC + Cubit)',
    'get_it',
    'equatable',
    'image_picker',
    'CustomPaint',
    'BackdropFilter'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['ios'],
  ARRAY['ios_developer', 'flutter_developer'],
  'Solo builder: Clean Architecture Flutter + Swift, MethodChannel bridge, Apple Vision integration, Golden Ratio algorithm, animasi UI.',
  'Solo project',
  '2026',
  $$Menunjukkan pemahaman cara kerja Flutter-to-Native bridge via MethodChannel, bagaimana data diserialkan dari Dart ke Swift dan kembali, serta bagaimana memisahkan native computation dari business logic lewat Clean Architecture sehingga layer Domain tidak tahu bahwa data berasal dari Apple Vision.$$,
  ARRAY[
    'MethodChannel sebagai bridge: Flutter mengirim list path via invokeMethod(), Swift menangkap di AppDelegate, menjalankan Vision, dan mengembalikan array Dictionary secara asynchronous.',
    'Vision-Phi Symmetry Engine: VNDetectFaceLandmarksRequest mengekstrak koordinat wajah, Swift menghitung Euclidean distance antar titik, membandingkan rasio dengan Phi (1.618), dan mengkonversi deviasi ke skor 0-100.',
    'Satu binary tunggal: Swift sebagai native host, Flutter dikompilasi ke C++ dan ditanam di dalam host yang sama; MethodChannel berkomunikasi via internal RAM bukan localhost.',
    'Clean Architecture: NativeAuraDataSource sebagai satu-satunya caller MethodChannel, AuraRepositoryImpl sebagai konverter Model ke Entity, CalculateAuraUseCase sebagai orkestrator, AuraCubit sebagai state manager.',
    'Animasi laser scanner via CustomPaint + AnimationController dipicu saat state Scanning, glassmorphism leaderboard card via BackdropFilter saat state Success.'
  ],
  $$Tiga lapisan Clean Architecture: Data (NativeAuraDataSource memanggil MethodChannel, AuraModel mem-parse Map dari Swift, AuraRepositoryImpl mengkonversi ke Entity), Domain (AuraEntity, IAuraRepository, CalculateAuraUseCase), dan Presentation (AuraCubit dengan state Initial/Scanning/Success/Error, UI yang murni reaktif terhadap state).

Domain layer tidak tahu bahwa data berasal dari Apple Vision atau MethodChannel. IAuraRepository hanya mendefinisikan kontrak calculateAuraScores(List<String> paths), dan implementasinya di Data layer yang mengurus detail bridge. Ini memungkinkan unit test Domain dan UseCase tanpa menyentuh native code.$$,
  $$Memilih MethodChannel alih-alih FFI untuk kasus ini karena Apple Vision Framework adalah Objective-C/Swift API yang tidak expose C function pointer, sehingga FFI tidak applicable. MethodChannel asynchronous cocok di sini karena Vision processing memang butuh waktu dan tidak perlu synchronous seperti audio DSP. Platform eksklusif iOS karena Vision Framework adalah teknologi Apple; Android tidak punya equivalent yang bisa dipakai dengan cara yang sama. Input terbatas ke galeri (bukan live camera) untuk menjaga scope MVP tetap fokus pada demonstrasi bridge dan Vision integration.$$,
  ARRAY[
    'Face landmark detection offline via Apple Neural Engine, tanpa internet.',
    'Public proof: repo publik di GitHub dengan dokumentasi TRD dan flowchart MethodChannel bridge.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/AuraApp',
  'public',
  3,
  DATE '2026-05-09',
  NOW(),
  NOW()
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  description = EXCLUDED.description,
  problem = EXCLUDED.problem,
  solution = EXCLUDED.solution,
  result = EXCLUDED.result,
  role = EXCLUDED.role,
  tech_stack = EXCLUDED.tech_stack,
  year = EXCLUDED.year,
  status = EXCLUDED.status,
  featured = EXCLUDED.featured,
  project_type = EXCLUDED.project_type,
  platforms = EXCLUDED.platforms,
  disciplines = EXCLUDED.disciplines,
  ownership = EXCLUDED.ownership,
  team_size = EXCLUDED.team_size,
  duration = EXCLUDED.duration,
  impact_summary = EXCLUDED.impact_summary,
  technical_highlights = EXCLUDED.technical_highlights,
  architecture_notes = EXCLUDED.architecture_notes,
  tradeoffs = EXCLUDED.tradeoffs,
  metrics = EXCLUDED.metrics,
  demo_url = EXCLUDED.demo_url,
  demo_video_url = EXCLUDED.demo_video_url,
  github_url = EXCLUDED.github_url,
  case_study_visibility = EXCLUDED.case_study_visibility,
  sort_order = EXCLUDED.sort_order,
  sort_date = EXCLUDED.sort_date,
  updated_at = NOW();

-- =====================================================================================
-- 3) LiquidGlassTabs — Custom Flutter Widget (BackdropFilter + CustomPainter + AnimatedPositioned)
-- =====================================================================================
INSERT INTO projects (
  id,
  title,
  slug,
  summary,
  description,
  problem,
  solution,
  result,
  role,
  tech_stack,
  year,
  status,
  featured,
  project_type,
  platforms,
  disciplines,
  ownership,
  team_size,
  duration,
  impact_summary,
  technical_highlights,
  architecture_notes,
  tradeoffs,
  metrics,
  demo_url,
  demo_video_url,
  github_url,
  case_study_visibility,
  sort_order,
  sort_date,
  inserted_at,
  updated_at
) VALUES (
  'c3333333-4444-5555-8666-777700000003',
  'LiquidGlassTabs — Custom Flutter Bottom Navigation Widget',
  'liquidglasstabs-flutter-custom-widget',
  $$Custom Flutter bottom navigation widget bergaya Apple liquid glass yang dibangun dari nol dengan BackdropFilter, CustomPainter, dan AnimatedPositioned, tanpa package UI eksternal, dengan API reusable.$$,
  $$LiquidGlassTabs adalah project eksplorasi Flutter yang membuktikan bahwa efek bottom navigation premium ala Apple liquid glass bisa dibangun sendiri secara modular tanpa bergantung pada package visual khusus. Widget ini memakai empat layer visual yang ditumpuk dengan urutan tertentu: floating capsule dengan blur, glass shell dengan highlight, active liquid bubble yang bisa di-drag, dan tab button per item. Hasilnya adalah komponen reusable dengan API bersih yang bisa dipasang di project Flutter lain.$$,
  $$Package bottom navigation Flutter yang ada di pub.dev umumnya tidak bisa dimodifikasi secara mendalam untuk kebutuhan visual spesifik, dan hasilnya tidak terasa seperti material kaca yang sesungguhnya. Memahami cara kerja BackdropFilter, CustomPainter, dan AnimatedPositioned secara langsung lebih berharga untuk portfolio engineering daripada memakai package yang menyembunyikan implementasinya.$$,
  $$Membangun LiquidGlassBottomTabBar sebagai widget reusable dengan empat layer visual. Layer 1 adalah floating capsule: SafeArea + ConstrainedBox + ClipRRect + BackdropFilter untuk blur konten di belakang tab (membutuhkan extendBody: true di Scaffold). Layer 2 adalah glass shell: warna charcoal semi-transparan + border putih tipis + _GlassShellPainter yang menambahkan highlight diagonal dan sheen. Layer 3 adalah active liquid bubble: AnimatedPositioned yang bergerak antar slot, dengan BackdropFilter kedua di dalam bubble, gradient glow, dan chromatic ring dari SweepGradient via _BubbleRefractionPainter. Layer 4 adalah tab button: _LiquidTabButton per item dengan icon, label, badge, tap target, scale animation, dan HapticFeedback.

Bubble aktif bisa di-drag horizontal antar tab; saat dilepas, widget memanggil onTap dengan tab terdekat. Lebar bubble dihitung dari lebar label aktif agar proporsinya presisi, bukan fixed width.$$,
  ARRAY[
    'Custom LiquidGlassBottomTabBar dengan API reusable: items, currentIndex, onTap.',
    'Empat layer visual yang ditumpuk: floating capsule blur, glass shell highlight, active liquid bubble, dan tab button per item.',
    'Draggable liquid bubble: active bubble bisa ditarik horizontal antar tab dan commit ke tab terdekat saat dilepas.',
    'Zero package dependency untuk efek visual: hanya Flutter SDK dan cupertino_icons.',
    'Dokumentasi breakdown per layer (LIQUID_GLASS_BREAKDOWN.md) dan cara integrasi ke project lain.'
  ],
  'Solo Flutter developer (eksplorasi UI engineering)',
  ARRAY[
    'Flutter',
    'Dart',
    'BackdropFilter',
    'CustomPainter',
    'AnimatedPositioned',
    'AnimatedScale',
    'AnimatedDefaultTextStyle',
    'SweepGradient',
    'HapticFeedback',
    'ClipRRect',
    'cupertino_icons'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['flutter'],
  ARRAY['flutter_developer'],
  'Solo builder: desain empat layer visual, implementasi CustomPainter untuk highlight dan chromatic ring, drag interaction, dan dokumentasi breakdown widget.',
  'Solo project',
  '2026',
  $$Menunjukkan pemahaman rendering pipeline Flutter: cara BackdropFilter bekerja dengan extendBody, cara CustomPainter dipakai untuk efek visual yang tidak bisa dicapai dengan widget standar, dan cara AnimatedPositioned dipakai untuk movement yang terasa liquid.$$,
  ARRAY[
    'BackdropFilter + ClipRRect untuk blur konten di belakang capsule; extendBody: true di Scaffold wajib agar konten benar-benar berada di belakang tab.',
    'CustomPainter dipakai dua kali: _GlassShellPainter untuk highlight diagonal dan sheen di shell luar, _BubbleRefractionPainter untuk gradient glow dan chromatic ring (SweepGradient) di bubble aktif.',
    'AnimatedPositioned untuk movement bubble dengan Curves.easeOutCubic; lebar bubble dihitung dari lebar label aktif agar proporsi presisi.',
    'Drag interaction: GestureDetector di bubble menangkap horizontal drag, posisi bubble mengikuti jari, onTap dipanggil dengan tab terdekat saat drag selesai.',
    'API reusable: LiquidGlassBottomTabBar menerima items (List<TabDestination>), currentIndex, dan onTap; TabDestination mendefinisikan label, icon, gradient, badge, dan avatar.'
  ],
  $$Arsitektur widget dipisahkan berdasarkan tanggung jawab: AppShell mengatur currentIndex, daftar TabDestination, IndexedStack, dan posisi tab bar; LiquidGlassBottomTabBar mengurus semua rendering efek kaca; helper widget dibuat private (_LiquidSelectionBubble, _LiquidTabButton, _Badge, _GlassShellPainter, _BubbleRefractionPainter) karena merupakan detail implementasi. Public API tetap kecil: hanya tiga parameter.

Tidak ada layer Data atau Domain karena project ini bukan aplikasi data-driven. Fokusnya adalah reusable visual system, sehingga arsitektur sengaja dibuat flat dan mudah dipindahkan ke project lain dengan mengambil tiga file: tab_destination.dart, liquid_glass_bottom_tab_bar.dart, dan app_theme.dart.$$,
  $$Memilih custom widget alih-alih package karena tujuan utama adalah memahami rendering pipeline Flutter secara mendalam, bukan sekadar menghasilkan efek visual. Konsekuensinya waktu implementasi lebih lama dan ada beberapa edge case (seperti lebar bubble di tablet) yang perlu ditangani manual. Efek ini mendekati Apple liquid glass secara visual tetapi belum melakukan refractive distortion fisik yang membelokkan pixel background; untuk level itu dibutuhkan fragment shader atau custom render pipeline yang di luar scope project ini.$$,
  ARRAY[
    'Zero external package untuk efek visual; hanya Flutter SDK.',
    'Public proof: repo publik di GitHub dengan dokumentasi LIQUID_GLASS_BREAKDOWN.md.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/flutter-liquidglass-bottomsheet',
  'public',
  3,
  DATE '2026-05-11',
  NOW(),
  NOW()
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  description = EXCLUDED.description,
  problem = EXCLUDED.problem,
  solution = EXCLUDED.solution,
  result = EXCLUDED.result,
  role = EXCLUDED.role,
  tech_stack = EXCLUDED.tech_stack,
  year = EXCLUDED.year,
  status = EXCLUDED.status,
  featured = EXCLUDED.featured,
  project_type = EXCLUDED.project_type,
  platforms = EXCLUDED.platforms,
  disciplines = EXCLUDED.disciplines,
  ownership = EXCLUDED.ownership,
  team_size = EXCLUDED.team_size,
  duration = EXCLUDED.duration,
  impact_summary = EXCLUDED.impact_summary,
  technical_highlights = EXCLUDED.technical_highlights,
  architecture_notes = EXCLUDED.architecture_notes,
  tradeoffs = EXCLUDED.tradeoffs,
  metrics = EXCLUDED.metrics,
  demo_url = EXCLUDED.demo_url,
  demo_video_url = EXCLUDED.demo_video_url,
  github_url = EXCLUDED.github_url,
  case_study_visibility = EXCLUDED.case_study_visibility,
  sort_order = EXCLUDED.sort_order,
  sort_date = EXCLUDED.sort_date,
  updated_at = NOW();
