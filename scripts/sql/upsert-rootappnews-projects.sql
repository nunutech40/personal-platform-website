-- Upsert recruiter-ready portfolio copy for RootAppNews learning ecosystem.
--
-- RootAppNews adalah ekosistem belajar full-stack konsumer news reader, terdiri dari:
--   - free-api-news    → https://github.com/nunutech40/open-api-free-news
--   - news-app         → https://github.com/nunutech40/news-app-flutter
--   - news-app-mvvm    → https://github.com/nunutech40/news-app-mvvm-flutter
--
-- Kedua Flutter app bekerja di backend yang sama; yang satu dipakai untuk latihan
-- MVVM + Provider + TDD, yang satu lagi dipakai untuk latihan Clean Architecture
-- berlapis lengkap (BLoC + Cubit + GoRouter + Firebase OTP + Google Sign-In +
-- compute() isolate untuk image processing). Karena keduanya Flutter development
-- (bukan backend engineering), disciplines hanya flutter_development.
--
-- Usage from repository root:
--   /opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-rootappnews-projects.sql

-- =====================================================================================
-- 1) free-api-news — Go + PostgreSQL News REST API (live backend untuk dua Flutter app)
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
  'b2222222-3333-4444-8555-666600000001',
  'free-api-news — REST API untuk News App Flutter',
  'free-api-news-backend-rest-api',
  $$REST API Go + PostgreSQL sebagai backend nyata untuk dua iterasi News App Flutter (Provider/MVVM dan BLoC/Clean Architecture), live di VPS dengan JWT access token dan refresh token rotation.$$,
  $$free-api-news adalah backend REST API yang dibangun untuk menemani project belajar Flutter. Daripada memakai public mock API, saya bikin sendiri dengan Go + PostgreSQL supaya bisa mendesain kontrak endpoint, error shape, dan alur auth yang pas untuk latihan Clean Architecture di sisi Flutter. API ini di-deploy ke VPS dan dipakai oleh dua app Flutter (news-app-mvvm dan news-app) sebagai single source of truth.$$,
  $$Latihan Flutter Clean Architecture yang layak butuh backend nyata, bukan mock. Mock server tidak mereproduksi latensi, error transport, token expiry, atau refresh rotation, sehingga layer data dan interceptor di Flutter tidak terlatih secara jujur. Mengandalkan public news API juga membatasi eksperimen fitur seperti bookmark server-side, admin article CRUD, atau kontrak error yang konsisten.$$,
  $$Membangun REST API Go dengan PostgreSQL berdasarkan struktur project modular (cmd, internal/config, domain, repository, service, handler, middleware, router, util, migrations). Autentikasi memakai JWT access token singkat 15 menit plus opaque refresh token 7 hari yang disimpan di tabel tokens dan dirotasi penuh setiap panggil /refresh. Endpoint bookmark, news feed, article detail, categories, dan admin article creation dirancang sesuai kebutuhan spesifik Flutter client, sehingga kontrak response terasa alami dari UI sampai backend.

Dokumentasi API ditulis lewat Swagger, migrasi dipegang sebagai file SQL berurutan, dan deploy ke VPS memakai Makefile plus systemd service. Dengan cara ini iterasi fitur di Flutter langsung punya backend pendampingnya di produksi, termasuk update profile, upload avatar, dan OAuth social login.$$,
  ARRAY[
    'Live di http://103.181.143.73:8081 dan dipakai oleh dua Flutter app (news-app-mvvm dan news-app) sebagai backend pendamping belajar.',
    'Swagger UI publik di /swagger/index.html dan health check di /health.',
    'Full auth lifecycle: register, login, logout, refresh dengan rotasi token, dan /auth/me untuk update profile.',
    'Endpoint news: categories, feed dengan pagination, article detail by slug, upload image, plus admin article creation.',
    'Migrasi SQL eksplisit plus deploy ke VPS via Makefile dan systemd service.'
  ],
  'Solo backend engineer + API designer',
  ARRAY[
    'Go 1.22',
    'PostgreSQL',
    'JWT (HS256)',
    'bcrypt',
    'Swagger (OpenAPI)',
    'Makefile',
    'systemd',
    'SQL migrations',
    'REST API',
    'IDCloudHost VPS (Ubuntu)'
  ],
  '2026',
  'published',
  TRUE,
  'personal_project',
  ARRAY['backend'],
  ARRAY['backend_engineering', 'architecture'],
  'Solo builder: desain skema, handler, service, SQL migrations, auth flow, Swagger doc, Makefile, deploy ke VPS, serta maintain endpoint berdasarkan kebutuhan dua Flutter client.',
  'Solo project',
  '2026',
  $$Menunjukkan kemampuan mendesain backend nyata untuk mendukung latihan Flutter Clean Architecture: kontrak endpoint yang rapi, token strategy dua-layer, error shape yang konsisten, dan deploy yang beneran live di VPS, bukan mock lokal.$$,
  ARRAY[
    'JWT access token 15 menit untuk stateless check plus opaque refresh token 7 hari di DB; /refresh merotasi pair dan merevoke refresh token lama.',
    'Skema DB terdokumentasi (users, tokens, categories, articles) dengan index khusus email, refresh_token, slug, published_at, dan flag is_revoked.',
    'Struktur project berlapis (domain, repository, service, handler, middleware, router) dengan util untuk JWT, bcrypt, dan response helper.',
    'Swagger (swagger.yaml + docs.go) menjadi kontrak acuan Flutter client supaya DTO di Dart tetap sinkron.',
    'Middleware CORS, request logger, dan graceful shutdown supaya deploy tidak tiba-tiba drop koneksi saat update.',
    'Upload image endpoint (multipart) untuk avatar profile yang nanti dipakai news-app dengan crop + compress di sisi Flutter.'
  ],
  $$Arsitektur modular per domain: domain (entities + interfaces) menjadi kontrak, repository mengurus akses PostgreSQL, service memegang business logic, handler menghubungkan HTTP dan service, middleware menangani CORS, logging, dan Bearer auth. Entry point cmd/api/main.go bertanggung jawab menyusun dependency dan menjalankan router dengan graceful shutdown.

Token strategy dirancang supaya Flutter client bisa belajar interceptor refresh: access token JWT HS256 15 menit disimpan di memory/secure storage, refresh token opaque 7 hari disimpan di tabel tokens dengan flag is_revoked, dan rotasi penuh dijalankan setiap /refresh dipanggil.$$,
  $$Memakai JWT + opaque refresh di tabel tokens alih-alih pure stateless karena ingin bisa merevoke refresh secara eksplisit saat logout atau rotasi; konsekuensinya tiap /refresh satu round trip ke DB. Migrasi SQL dikelola manual dengan file berurutan alih-alih framework seperti goose atau migrate; cukup untuk skala project belajar dan membuat setiap perubahan skema tetap terbaca. Swagger ditulis manual (bukan generated dari struct tags) untuk kontrol penuh pada shape response, trade-off-nya perlu disiplin menjaga swagger dan implementasi tetap sejalan.$$,
  ARRAY[
    'Access token TTL 15 menit dan refresh token TTL 7 hari dengan rotasi penuh setiap /refresh.',
    'Endpoint terdokumentasi: auth (register/login/logout/refresh/me), news (categories/feed/detail), upload, admin article create.',
    'Public proof: live di http://103.181.143.73:8081 dan Swagger UI di /swagger/index.html.'
  ],
  'http://103.181.143.73:8081/swagger/index.html',
  NULL,
  'https://github.com/nunutech40/open-api-free-news',
  'public',
  1,
  DATE '2026-04-30',
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
-- 2) news-app-mvvm — Pragmatic MVVM + Provider (Flutter learning project, TDD-first)
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
  'b2222222-3333-4444-8555-666600000002',
  'News App (MVVM + Provider) — Flutter Learning Project',
  'news-app-mvvm-flutter-learning',
  $$Flutter news reader sebagai project belajar MVVM + Provider dengan pragmatic Clean Architecture empat lapisan dan disiplin TDD pada ViewModel dan Repository, memakai free-api-news sebagai backend.$$,
  $$news-app-mvvm adalah salah satu dari dua iterasi project belajar Flutter yang saya kerjakan di bawah payung RootAppNews. Fokus dari iterasi ini adalah merasakan langsung MVVM + Provider sebagai state management ringan di atas pragmatic Clean Architecture yang sengaja dipangkas dari delapan lapisan penuh menjadi empat lapisan esensial. Aplikasi ini dipasangkan dengan backend free-api-news yang saya tulis sendiri di Go + PostgreSQL, supaya latihan arsitektur tidak berhenti di mock.$$,
  $$Belajar Flutter Clean Architecture kalau langsung mengadopsi delapan lapisan penuh terasa kelebihan beban untuk iterasi pertama, sehingga sering berakhir di boilerplate tanpa pemahaman jujur. Selain itu latihan dengan mock API menyembunyikan issue konkret seperti kontrak error, rotasi token, dan lifecycle ViewModel, sehingga ketika pindah ke kasus nyata banyak asumsi yang jebol.$$,
  $$Membangun Flutter app dengan MVVM + Provider (ChangeNotifier) pada pragmatic Clean Architecture empat lapisan: Presentation (Pages, Widgets, ViewModel), Repository (interface + implementasi digabung untuk iterasi), Models (entity + data object digabung), dan Core (ApiClient Dio, Either/Failure, GetIt). Response network secara konsisten dibungkus dengan Either<Failure, T> agar error menjadi nilai eksplisit, bukan exception tersembunyi di alur UI.

Disiplin TDD dipakai pada ViewModel dan Repository: siklus red-green-refactor dijalankan dengan mocktail tanpa build_runner, sehingga iterasi test cepat. Routing memakai go_router dengan redirect berbasis status auth, dan dependency injection memakai get_it untuk menghindari passing constructor manual di hierarki widget yang dalam.$$,
  ARRAY[
    'Flutter news reader end-to-end terhubung ke free-api-news live di VPS.',
    'MVVM + Provider (ChangeNotifier) dipakai konsisten di AuthViewModel, NewsFeedViewModel, BookmarkViewModel, ArticleDetailViewModel, ExploreViewModel, dan SearchViewModel.',
    'Repository layer dibungkus Either<Failure, T> memakai dartz, error ditangani di presentation layer sebagai state.',
    'TDD diterapkan di ViewModel dan Repository dengan mocktail tanpa build_runner.',
    'Navigasi go_router dengan redirect auth-aware dan DI via get_it.'
  ],
  'Solo Flutter developer (learning project)',
  ARRAY[
    'Flutter',
    'Dart',
    'Provider (ChangeNotifier)',
    'dio',
    'dartz (Either/Failure)',
    'equatable',
    'go_router',
    'get_it',
    'shared_preferences',
    'flutter_secure_storage',
    'cached_network_image',
    'shimmer',
    'image_picker',
    'mocktail'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['flutter'],
  ARRAY['flutter_development'],
  'Solo builder: arsitektur MVVM + Provider, Repository layer, integrasi ke free-api-news, TDD ViewModel dan Repository, plus routing dan DI.',
  'Solo learning project',
  '2026',
  $$Menunjukkan pemahaman jujur soal state management Flutter: memilih MVVM + Provider sebagai pendekatan ringan, memisahkan ViewModel dari akses API, dan menjaga UI tetap reaktif lewat ChangeNotifier. Sekaligus membuktikan kemampuan menulis test yang bermakna pada ViewModel dan Repository, bukan sekadar mengejar coverage.$$,
  ARRAY[
    'Arsitektur empat lapisan pragmatis: Presentation (ViewModel + Pages + Widgets), Repository (interface + implementasi), Models, dan Core (ApiClient, Either/Failure, GetIt).',
    'Response layer selalu Either<Failure, T> memakai dartz sehingga error tidak bocor sebagai exception ke UI.',
    'TDD red-green-refactor pada ViewModel dan Repository dengan mocktail, tanpa build_runner.',
    'go_router dengan redirect auth-aware dan dependency injection via get_it untuk menghindari prop drilling.',
    'Integrasi ke backend sendiri (free-api-news) dengan interceptor Dio untuk injection Bearer token dan handler refresh dasar.',
    'Equatable dipakai pada entity dan state supaya value equality konsisten untuk test dan rebuild selektif.'
  ],
  $$Pragmatic Clean Architecture diterapkan dengan empat lapisan: Presentation, Repository (interface + implementasi disatukan untuk menjaga iterasi cepat), Models (entity dan data object disatukan), dan Core. Dependency rule tetap dijaga: UI dan ViewModel hanya berbicara dengan Repository, Repository mengkonsumsi ApiClient Dio, dan Model berperan ganda sebagai JSON serializer plus value object.

ViewModel berbasis ChangeNotifier dan di-inject ke tree via ChangeNotifierProvider, dan Consumer dipakai di UI untuk rebuild granular sesuai field yang berubah. Dependency injection dipegang GetIt secara singleton atau factory sesuai kebutuhan, dan routing memakai go_router dengan refresh listenable supaya redirect auth merespons perubahan state.$$,
  $$Memangkas Clean Architecture menjadi empat lapisan demi kecepatan iterasi; konsekuensinya ketika nanti diperluas ke proyek tim atau domain yang lebih besar, UseCase layer mungkin perlu dihadirkan kembali. MVVM + Provider dipilih alih-alih BLoC karena lebih ringan dan cocok untuk belajar pattern Method-driven terlebih dahulu; trade-off-nya kurang event traceability kalau dibandingkan BLoC. Interface Repository tidak dipisah ke file sendiri di iterasi ini untuk menghindari jumlah file yang meledak, tetapi siap dipisahkan saat modul tumbuh.$$,
  ARRAY[
    'Endpoint dasar yang dikonsumsi: auth (register/login/logout/refresh/me), news (categories/feed/detail), plus bookmark.',
    'Public proof: backend pendamping live di http://103.181.143.73:8081 dan repo Flutter publik di GitHub.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/news-app-mvvm-flutter',
  'public',
  2,
  DATE '2026-04-15',
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
-- 3) news-app — Full Clean Architecture + BLoC + Firebase OTP + Google OAuth +
--    compute() isolate untuk image processing (Flutter learning project, extended)
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
  'b2222222-3333-4444-8555-666600000003',
  'News App (BLoC + Clean Architecture) — Flutter Learning Project Lanjutan',
  'news-app-flutter-clean-architecture',
  $$Iterasi lanjutan dari news-app-mvvm dengan arsitektur Clean Architecture lengkap, BLoC + Cubit, Firebase OTP untuk reset password, Google Sign-In, dan compute() isolate untuk crop dan compress avatar di profile.$$,
  $$news-app adalah iterasi lanjutan dari news-app-mvvm yang mengeksplorasi Clean Architecture berlapis lengkap pada Flutter, dipasangkan dengan backend free-api-news yang sama. Fokus dari iterasi ini adalah masuk ke topik yang jarang ditemui di project tutorial: interceptor Dio dengan refresh token lock, BLoC plus Cubit untuk kebutuhan state yang berbeda, Firebase OTP sebagai lapisan verifikasi HP untuk reset password, Google Sign-In OAuth, serta image processing berat di Dart Isolate melalui compute() supaya UI tetap smooth saat upload avatar.$$,
  $$Setelah mengerti MVVM + Provider di iterasi pertama, masih ada banyak area Flutter yang belum tersentuh seperti interceptor dengan refresh lock, event traceability BLoC, OAuth Google, OTP via Firebase, dan image processing yang tidak membekukan UI. Mengerjakan semuanya di project yang sama memungkinkan setiap keputusan arsitektur saling mendukung, bukan sekadar menempel tutorial terpisah.$$,
  $$Membangun Flutter app memakai Clean Architecture berlapis lengkap: Presentation (Pages, Widgets, BLoC/Cubit), Domain (Entities, UseCases, Repository contract), Data (Models, Repository impl, RemoteDatasource, LocalDatasource), dan Core (ApiClient Dio, AuthInterceptor, ErrorHandling, DI, theme, router). Return type di boundary domain-repository konsisten Either<Failure, T>. BLoC dipakai untuk state global seperti AuthBloc, Cubit dipakai untuk state lokal per layar (feed, explore, search, bookmark, article detail, profile edit).

Auth stack mendalam: login email/password ke backend, Google Sign-In lewat official plugin, Firebase OTP untuk reset password (verifyPhoneNumber dan signInWithCredential, lalu menukar Firebase ID Token ke backend), plus auth interceptor dengan lock supaya refresh token race condition tidak terjadi saat beberapa request paralel kena 401. Untuk update profile, image dari kamera atau galeri dipindah ke Isolate via compute() untuk crop square dan encode JPEG, sehingga Main Thread tetap responsif walau file asli besar.$$,
  ARRAY[
    'Flutter news reader versi lanjutan dengan modul Auth, Dashboard, News Feed, Explore, Search, Bookmark, Article Detail, dan Profile.',
    'Auth lengkap: email/password, Google Sign-In, dan reset password via Firebase OTP (verifyPhoneNumber + signInWithCredential) yang menukar Firebase ID Token ke backend.',
    'Dio AuthInterceptor dengan refresh token lock sehingga race condition saat banyak request paralel kena 401 tidak menyebabkan rotasi token ganda.',
    'Bookmark pakai optimistic update lokal via SharedPreferences yang sinkron ke backend.',
    'Update avatar di profile memakai compute() isolate untuk crop square + JPEG compress (image package) supaya UI tetap smooth walau foto asli 20MB.'
  ],
  'Solo Flutter developer (learning project lanjutan)',
  ARRAY[
    'Flutter 3.38',
    'Dart 3.6',
    'flutter_bloc (BLoC + Cubit)',
    'dio',
    'dartz (Either/Failure)',
    'equatable',
    'go_router',
    'get_it',
    'injectable',
    'flutter_secure_storage',
    'shared_preferences',
    'firebase_core',
    'firebase_auth',
    'firebase_crashlytics',
    'google_sign_in',
    'pinput',
    'image (isolate crop/compress)',
    'image_picker',
    'cached_network_image',
    'shimmer',
    'google_fonts',
    'flutter_local_notifications',
    'bloc_test',
    'mocktail',
    'http_mock_adapter'
  ],
  '2026',
  'published',
  TRUE,
  'personal_project',
  ARRAY['flutter'],
  ARRAY['flutter_development'],
  'Solo builder: arsitektur Clean Architecture berlapis lengkap, integrasi Firebase OTP, Google Sign-In, Dio AuthInterceptor dengan refresh lock, image processing di Isolate, plus modul News Feed, Explore, Search, Bookmark, Article Detail, dan Profile.',
  'Solo learning project',
  '2026',
  $$Menunjukkan kemampuan meramu Clean Architecture Flutter dengan state management BLoC plus Cubit secara proporsional, menangani integrasi third-party yang umum ditemui di production (Firebase OTP, Google OAuth), dan memahami batas antara Main Thread dan Isolate ketika beban komputasi berat seperti decode image muncul di alur UI.$$,
  ARRAY[
    'Clean Architecture lengkap per feature dengan Domain, Data, Presentation, dan Core, serta Either<Failure, T> di boundary domain-repository.',
    'BLoC dipakai untuk state global AuthBloc dan GlobalAlertBloc untuk network error; Cubit dipakai untuk state lokal per layar (feed, explore, search, bookmark, article detail, profile edit).',
    'Dio AuthInterceptor dengan refresh token lock mencegah race condition saat beberapa request paralel kena 401 secara bersamaan.',
    'Firebase OTP untuk reset password: verifyPhoneNumber lalu signInWithCredential, Firebase ID Token ditukar ke backend untuk update password final.',
    'Google Sign-In menggunakan plugin resmi sehingga dapat memanfaatkan native credential manager Android dan iOS.',
    'Isolate image processing via compute() top-level function: decode, copyResizeCropSquare, encodeJpg dengan quality configurable, sehingga file 10-30MB diturunkan ke puluhan KB tanpa membekukan UI.',
    'Optimistic bookmark di SharedPreferences dengan sinkronisasi ke backend untuk pengalaman instan walau koneksi lambat.',
    'Storage dua jenis: flutter_secure_storage untuk token (Keychain/EncryptedSharedPreferences) dan shared_preferences untuk cache non-sensitif seperti profile dan bookmark.'
  ],
  $$Feature-first dengan lapisan tegas: Presentation (Pages, Widgets, BLoC/Cubit), Domain (Entities, UseCases, Repository contract), Data (Models, Repository impl, RemoteDatasource, LocalDatasource), dan Core (ApiClient, AuthInterceptor, Failure, DI, router, theme). Dependency rule: Presentation tidak pernah memanggil ApiClient langsung, semua lewat UseCase ke Repository interface.

External dependency dibungkus sesuai siapa yang mengonsumsinya. Dio dan SecureStorage dibungkus sebagai Datasource karena dipakai RepositoryImpl di Data layer, sedangkan Firebase OTP dan flutter_local_notifications dibungkus sebagai Service atau Repository khusus karena dipakai sebagai orkestrasi multi-sumber dari UseCase atau Repository. Misalnya AuthRepositoryImpl berperan sebagai dirigen: menerima request dari UseCase, berkoordinasi dengan FirebaseOTPService untuk verifikasi HP, menukar credential ke backend lewat AuthRemoteDatasource, lalu menyimpannya via AuthLocalDatasource.$$,
  $$Memilih BLoC untuk AuthBloc dan Cubit untuk state lokal per layar sebagai kompromi antara event traceability dan ringkasnya boilerplate, bukan full-BLoC di setiap layar. Memakai Firebase OTP alih-alih membangun SMS Gateway sendiri karena biaya dan manajemen bot spam terlalu mahal untuk project belajar; konsekuensinya ada ketergantungan ke layanan Google. Bookmark optimistic update disimpan di SharedPreferences supaya terasa instan, trade-off-nya perlu logic rekonsiliasi ketika backend dan local tidak sinkron.

Compute() isolate dipakai spesifik untuk crop dan compress image; tidak dipakai untuk parse JSON ringan karena overhead Isolate tidak sebanding untuk payload kecil. UseCase layer dipertahankan walaupun banyak yang tipis karena tujuan utama iterasi ini adalah latihan Clean Architecture berlapis.$$,
  ARRAY[
    'Modul yang sudah live: Dashboard (5 tab), News Feed, Explore, Search dengan debounce + pagination, Bookmark dengan optimistic update, Article Detail, dan Profile dengan edit avatar via Isolate.',
    'Integrasi Firebase OTP, Google Sign-In, dan Firebase Crashlytics pada auth flow.',
    'Public proof: backend pendamping live di http://103.181.143.73:8081 dan repo Flutter publik di GitHub.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/news-app-flutter',
  'public',
  2,
  DATE '2026-04-29',
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
