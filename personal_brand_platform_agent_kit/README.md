# Personal Brand Platform Agent Kit

Agent kit ini berisi instruksi kerja untuk AI coding agent yang membangun Personal Brand Platform.

Target utama:

```txt
Phoenix LiveView + Supabase + themeable personal brand platform
```

## How To Use

Untuk fresh/new chat, agent harus membaca:

1. `../README.md`
2. `../docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md`
3. `../docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md`
4. skill yang relevan di `.agents/skills/*/SKILL.md`

Untuk chat yang sudah punya konteks dan baru meneruskan task kecil:

```txt
1. Jangan baca ulang semua dokumen.
2. Baca ulang hanya section building plan yang relevan dengan slice.
3. Baca skill yang relevan.
4. Cek git status dan file sekitar perubahan.
```

## Skill Design Direction

Skill sebaiknya seperti Flutter skills: bukan “fitur produk X”, tapi kemampuan repetitif yang bisa dipakai berkali-kali.

Contoh pola yang benar:

```txt
building forms
working with database schemas
implementing routing
theming interfaces
handling file uploads
integrating external checkout
testing public pages
```

Contoh pola yang terlalu spesifik:

```txt
build products page for Nunu
make Midtrans for this project
create admin dashboard exactly like current mockup
```

## Recommended Skill Set

Gunakan skill generik ini untuk pekerjaan berikutnya:

```txt
pbp-coding-elixir-functionally
pbp-architecting-phoenix-platforms
pbp-modeling-content-data
pbp-building-liveview-pages
pbp-building-admin-forms
pbp-theming-public-interfaces
pbp-managing-publishing-workflows
pbp-handling-media-assets
pbp-integrating-external-checkout
pbp-testing-and-qa
```

Untuk pekerjaan backend, Supabase, Phoenix contexts, LiveView event handlers, atau integrasi eksternal, mulai dari `pbp-coding-elixir-functionally`, lalu lanjutkan ke skill domain yang relevan.

Skill lama yang feature-specific sudah dihapus. Kalau butuh detail project seperti field, route, dan phase, ambil dari root docs:

```txt
../docs/planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md
../docs/architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md
```

## Skill Quality Checklist

Setiap `SKILL.md` harus:

- punya frontmatter `name` dan `description`
- menjelaskan kapan skill dipakai
- memberi workflow yang repeatable
- memberi checklist verifikasi
- menghindari detail konten yang terlalu hardcoded
- mengarahkan agent ke dokumen project jika butuh field/route spesifik
- tetap pendek; detail besar sebaiknya masuk reference file terpisah
