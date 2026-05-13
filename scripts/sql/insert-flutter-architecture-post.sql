-- Insert: Post tentang Flutter Official Architecture Recommendation (MVVM)
INSERT INTO posts (
  id, title, slug, excerpt, content_markdown, content_html,
  editor_type, tags, status, featured, published_at, reading_time,
  inserted_at, updated_at
) VALUES (
  gen_random_uuid(),
  'Flutter Resmi Rekomendasikan MVVM — Ini Arsitektur yang Mereka Mau',
  'flutter-resmi-rekomendasikan-mvvm',
  'Flutter akhirnya punya opini resmi soal arsitektur app. Bukan Clean Architecture, bukan BLoC pattern — tapi MVVM dengan separation yang jelas antara UI layer dan Data layer.',
  '## Konteks

Selama bertahun-tahun, komunitas Flutter debat soal arsitektur. Ada yang pakai Clean Architecture ala Uncle Bob, ada yang all-in BLoC, ada yang bikin sendiri. Flutter sendiri diam — tidak pernah secara resmi bilang "pakai ini."

Sampai akhirnya, di docs.flutter.dev/app-architecture, Flutter team publish panduan arsitektur resmi. Dan pilihannya: **MVVM** (Model-View-ViewModel).

Bukan BLoC. Bukan Clean Architecture. Bukan MVC.

## Apa yang Flutter Rekomendasikan?

Intinya sederhana. App kamu harus dibagi jadi **dua layer**:

1. **UI Layer** — Views + ViewModels
2. **Data Layer** — Repositories + Services

Dan di dalam dua layer itu, ada 4 komponen utama:

1. **Views** — Widget yang render UI. Tidak boleh ada logic bisnis di sini.
2. **ViewModels** — Mengelola state dan logic UI. Satu ViewModel per satu View.
3. **Repositories** — Source of truth untuk data. Handle caching, retry, error handling.
4. **Services** — Wrapper untuk external API (REST, local file, platform API).

## Kenapa MVVM?

Flutter team kasih alasan yang cukup pragmatis:

1. **Separation of concerns** — Widget tetap "bodoh", logic ada di ViewModel.
2. **Testability** — ViewModel bisa di-test tanpa widget. Repository bisa di-mock.
3. **Maintainability** — Setiap komponen punya tanggung jawab yang jelas.
4. **Scalability** — Kalau app makin besar, tinggal tambah Domain Layer (use-cases).

## Bukan Berarti BLoC Salah

Penting untuk dipahami: ini bukan berarti BLoC atau Clean Architecture salah. Flutter team bilang ini "recommendations, not steadfast rules." Tapi ini pertama kalinya mereka secara resmi punya opini.

Dan kalau kamu perhatikan, banyak prinsip BLoC yang sebenarnya sudah align dengan MVVM:

- BLoC = ViewModel (keduanya handle logic dan state)
- Repository pattern = sama persis
- Service layer = sama persis

Bedanya: MVVM lebih simpel. Tidak ada event/state boilerplate yang kadang overkill untuk fitur sederhana.

## Rekomendasi Prioritas dari Flutter Team

Flutter team bahkan kasih level prioritas untuk setiap rekomendasi:

### Strongly Recommend (Wajib)

1. Pisahkan UI layer dan Data layer
2. Pakai Repository pattern di Data layer
3. Pakai ViewModel + View di UI layer (MVVM)
4. Jangan taruh logic di widget
5. Pakai dependency injection
6. Pakai immutable data models
7. Pakai unidirectional data flow
8. Pakai abstract repository classes
9. Test setiap komponen secara terpisah

### Recommend (Sebaiknya)

1. Pakai Commands untuk handle user events
2. Pakai freezed atau built_value untuk data models
3. Pakai go_router untuk navigation
4. Pakai naming convention yang konsisten

### Conditional (Kalau Perlu)

1. Pakai ChangeNotifier untuk state management
2. Pakai Domain Layer (use-cases) untuk app yang sangat kompleks
3. Pisahkan API models dan domain models untuk app besar

## Yang Menarik: Domain Layer Opsional

Banyak developer yang langsung jump ke Clean Architecture dengan use-cases di mana-mana. Flutter team bilang: **jangan, kecuali memang perlu.**

Domain layer (use-cases/interactors) hanya dibutuhkan kalau:

1. Ada logic yang perlu merge data dari multiple repositories
2. Logic-nya terlalu kompleks untuk ViewModel
3. Logic yang sama dipakai di banyak ViewModel

Kalau app kamu belum sampai situ, use-cases cuma nambah boilerplate tanpa manfaat nyata.

## Contoh Struktur yang Direkomendasikan

Untuk satu fitur, strukturnya kira-kira:

```
lib/
  features/
    home/
      home_view.dart          # Widget/UI
      home_viewmodel.dart     # Logic + State
  data/
    repositories/
      user_repository.dart    # Source of truth
    services/
      api_service.dart        # HTTP calls
    models/
      user.dart               # Immutable data model
```

Setiap fitur punya View + ViewModel sendiri. Repository dan Service di-share antar fitur lewat dependency injection.

## Pendapat Pribadi

Aku suka arah ini karena beberapa alasan:

1. **Pragmatis** — Tidak over-engineering. Mulai simpel, tambah layer kalau perlu.
2. **Familiar** — Kalau kamu pernah pakai MVVM di Android (Jetpack) atau iOS (SwiftUI), transisi ke Flutter jadi natural.
3. **Testable by default** — Separation yang jelas bikin testing jadi straightforward.
4. **Tidak dogmatis** — Flutter team bilang "adapt to your needs", bukan "harus persis begini."

Yang kurang: docs belum kasih guidance yang cukup soal state management choice. Mereka bilang ChangeNotifier "conditional" tapi tidak strongly recommend alternatif spesifik. Ini masih area abu-abu.

## Kesimpulan

Kalau kamu mulai project Flutter baru di 2025-2026, ini baseline yang bagus:

1. Pisahkan UI dan Data layer
2. Pakai MVVM (View + ViewModel)
3. Repository sebagai source of truth
4. Service untuk external API
5. Dependency injection (provider atau get_it)
6. Immutable models (freezed)
7. Tambah use-cases hanya kalau ViewModel mulai terlalu gemuk

Tidak perlu langsung Clean Architecture dengan 15 folder. Mulai dari sini, grow kalau perlu.

## Referensi

- [Flutter App Architecture Guide](https://docs.flutter.dev/app-architecture/guide)
- [Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Architecture Case Study (Compass App)](https://docs.flutter.dev/app-architecture/case-study)
',
  NULL,
  'markdown',
  ARRAY['Flutter', 'Architecture', 'MVVM', 'Mobile Development'],
  'published',
  false,
  NOW(),
  8,
  NOW(), NOW()
);
