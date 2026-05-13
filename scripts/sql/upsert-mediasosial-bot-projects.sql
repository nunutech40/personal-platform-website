-- Upsert recruiter-ready portfolio copy untuk 2 project mediasosial-bot.
--
-- Dua project X (Twitter) auto-posting dengan pendekatan berbeda:
--   - openclaw-bot  → https://github.com/nunutech40/mediasosial-bot (monorepo)
--     Python murni, tanpa platform AI agent. Latihan membangun automation workflow
--     sendiri dari nol: scheduler, LLM via CLI subprocess, hook scoring, A/B test.
--   - film-x-bot    → bagian dari monorepo yang sama
--     Implementasi OpenClaw platform (local), LLM via MiniMax M2.7, multi-agent
--     self-improving dengan 7 agent, reflexion loop, dan brain state.
--
-- Usage from repository root:
--   /opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-mediasosial-bot-projects.sql

-- =====================================================================================
-- 1) openclaw-bot — Python Auto-Posting X Bot (Tanpa Platform, Dibangun Sendiri)
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
  'd4444444-5555-6666-8777-888800000001',
  'openclaw-bot — Python X Auto-Posting Bot (Dibangun Sendiri, Tanpa Platform)',
  'openclaw-bot-python-x-autoposting',
  $$Python bot yang memposting otomatis ke X (Twitter) 3x sehari dengan konten niche ekonomi-karir Indonesia, dibangun dari nol tanpa platform AI agent: scheduler, Claude via CLI subprocess, hook scoring berbasis neuroscience, dan A/B testing model copywriting.$$,
  $$openclaw-bot adalah project latihan membangun automation workflow AI dari nol, tanpa bergantung pada platform seperti n8n, Zapier, atau OpenClaw. Bot berjalan di VPS via PM2, menjadwalkan posting 3x sehari, mengambil berita dari Google News RSS, menilai relevansi berita dengan hook scoring berbasis neuroscience (AMYGDALA, LOSS_AVERSION, RAS_SPECIFICITY, CURIOSITY_GAP, PRACTICAL_VALUE), lalu mengirim prompt ke Claude Sonnet via CLI subprocess untuk generate tweet. Hasilnya diposting ke akun @DerryNassu via Tweepy X API.$$,
  $$Membangun automation workflow AI yang berjalan 24/7 di VPS membutuhkan pemahaman tentang process management, scheduling yang tidak bergantung pada cron yang bisa miss, integrasi LLM tanpa SDK resmi (via CLI subprocess), dan strategi anti-bot detection. Menggunakan platform siap pakai menyembunyikan semua kompleksitas ini dan tidak menghasilkan pemahaman yang bisa ditransfer ke konteks lain.$$,
  $$Membangun seluruh stack dari nol dengan Python. Scheduler memakai library `schedule` yang berjalan dalam loop di worker.py, dikelola PM2 di VPS agar tetap hidup 24/7. Riset konten memakai Google News RSS (gratis, tidak kena blokir datacenter) dengan hook scoring lokal berbasis keyword neuroscience tanpa token LLM. Top 5 berita dengan skor tertinggi dikirim ke Claude sebagai konteks.

Claude dipanggil via `subprocess.run(["claude", "--print", "-p", prompt])` — memanfaatkan Claude Code CLI yang sudah terinstall di VPS, bukan SDK Python. Ini memungkinkan penggunaan model terbaru tanpa update dependency. Prompt dibangun berlapis: persona @DerryNassu, mode konten (9 mode), universal output rules, dan _trim_prompt() untuk normalisasi whitespace sebelum dikirim.

A/B testing dijalankan dengan dua model prompt paralel (Original dengan 9 mode terstruktur vs Challenger dengan judgment bebas Claude) pada akun yang sama, dengan laporan harian via Telegram jam 21:00.$$,
  ARRAY[
    'Bot berjalan 24/7 di VPS via PM2, posting 3x sehari ke @DerryNassu dengan jadwal dinamis per hari.',
    'Hook scoring lokal berbasis neuroscience (AMYGDALA 4x, LOSS_AVERSION 3x, RAS_SPECIFICITY 3x, CURIOSITY_GAP 2x, PRACTICAL_VALUE 1x) tanpa token LLM.',
    'A/B testing dua model copywriting (Original 9 mode vs Challenger judgment bebas) dengan laporan harian via Telegram.',
    'Guardian _is_valid_tweet() menolak output meta Claude (balik nanya, minta klarifikasi) dengan auto-retry 3x.',
    'SEO Page Builder 2x seminggu: generate halaman HTML dari keyword queue, deploy ke VPS, laporan mingguan via Telegram.',
    'Artikel panjang 2x seminggu (800-1500 karakter) dengan struktur Hook → Struggle → Turning Point → Solusi → Fakta Pahit → CTA.'
  ],
  'Solo engineer (automation + AI workflow)',
  ARRAY[
    'Python 3',
    'schedule (library)',
    'PM2 (process manager)',
    'Claude Sonnet (via claude CLI subprocess)',
    'subprocess (Python stdlib)',
    'Tweepy (X API v2)',
    'Google News RSS (feedparser)',
    'TwitterAPI.io (paid, untuk X search)',
    'DuckDuckGo (DDG search)',
    'Telegram Bot API',
    'Ubuntu VPS',
    'rsync + deploy.sh'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['backend'],
  ARRAY['backend_engineering'],
  'Solo builder: desain seluruh pipeline dari scheduler sampai posting, hook scoring system, prompt architecture berlapis, A/B testing framework, SEO builder, dan deploy ke VPS.',
  'Solo project',
  '2026',
  $$Menunjukkan kemampuan merancang automation workflow AI end-to-end dari nol: process management di VPS, integrasi LLM via CLI subprocess (bukan SDK), hook scoring lokal tanpa token, dan A/B testing framework yang berjalan di production.$$,
  ARRAY[
    'Claude dipanggil via subprocess.run(["claude", "--print", "-p", prompt]) — memanfaatkan Claude Code CLI di VPS, bukan Python SDK. Flag --print menonaktifkan interactive mode dan agent loop, menghasilkan satu teks output per call.',
    'Hook scoring lokal berbasis neuroscience: keyword AMYGDALA (4x), LOSS_AVERSION (3x), RAS_SPECIFICITY (3x), CURIOSITY_GAP (2x), PRACTICAL_VALUE (1x) — zero token, dijalankan sebelum LLM dipanggil.',
    'Cross-pool selection: gabungan ~10-20 kandidat tweet dari TwitterAPI.io (scoring: replies×5 + likes + rts − umur×0.1) dan ~24 berita RSS, dinormalisasi ke skala 0-1, lalu weighted random sampling pilih 5 referensi.',
    'Prompt architecture berlapis: persona → mode konten → _UNIVERSAL_OUTPUT_RULES (di-append sekali di tweet_writer, bukan di tiap mode) → _trim_prompt() untuk normalisasi whitespace.',
    'Guardian _is_valid_tweet() menolak output meta Claude sebelum posting; auto-retry 3x dengan jeda 30 detik; Telegram alert jika semua gagal.',
    'Cache riset SEO 7 hari ke disk (md5 keyword sebagai filename) untuk skip DDG call dan scraping jika keyword sama muncul kembali dalam rentang tersebut.',
    'Jeda acak 30 detik - 6 menit setelah generate sebelum posting untuk anti-bot detection.'
  ],
  $$Dua proses PM2 berjalan bersamaan: worker.py (scheduler utama: tweet, artikel, hunter reply) dan chatbot.py (Telegram bot: terima perintah dan handle approval untuk hunter reply). Keduanya harus hidup bersamaan karena tombol approve/reject di Telegram diproses oleh chatbot.py.

Arsitektur skill modular: setiap kemampuan (claude_agent, tweet_writer, riset, artikel_writer, hunter_reply, seo_riset) adalah modul terpisah dengan satu tanggung jawab. worker.py sebagai orchestrator memanggil skill yang tepat berdasarkan jadwal dan mode. Ini memungkinkan improve satu skill tanpa menyentuh yang lain.$$,
  $$Memilih Claude CLI subprocess alih-alih Python SDK karena CLI selalu menggunakan model terbaru tanpa update dependency, dan flag --print menghasilkan output bersih tanpa overhead agent loop. Konsekuensinya error handling lebih manual (cek returncode dan stdout). Google News RSS dipilih alih-alih paid news API karena gratis, tidak kena blokir datacenter VPS, dan cukup untuk hook scoring berbasis keyword. TwitterAPI.io dipakai hanya untuk X search (paid ~$0.0015/call) karena X API read resmi berbayar $100/M token. Jadwal dinamis per hari (WEEKLY_MODE_MATRIX) alih-alih jadwal tetap untuk mengurangi pola yang terdeteksi sebagai bot.$$,
  ARRAY[
    'Sekitar 23 konten per minggu: 21 tweet harian (3x/hari × 7 hari) + 2 artikel panjang.',
    'Dua proses PM2 berjalan paralel: worker.py dan chatbot.py.',
    'Cache SEO 7 hari menghemat DDG call dan scraping untuk keyword yang berulang.',
    'Public proof: repo publik di GitHub dengan dokumentasi TRD dan flowchart lengkap.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/mediasosial-bot',
  'public',
  2,
  DATE '2026-04-18',
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
-- 2) film-x-bot — Multi-Agent Self-Improving X Bot via OpenClaw + MiniMax M2.7
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
  'd4444444-5555-6666-8777-888800000002',
  'film-x-bot — Multi-Agent Self-Improving X Bot (OpenClaw + MiniMax M2.7)',
  'film-x-bot-multi-agent-openclaw-minimax',
  $$Multi-agent content system untuk akun X niche film Indonesia yang berjalan di OpenClaw lokal dengan LLM MiniMax M2.7, 7 agent dengan peran berbeda, reflexion loop, dan brain state yang diperbarui otomatis dari data performa nyata.$$,
  $$film-x-bot adalah implementasi nyata OpenClaw platform di lokal (bukan VPS) untuk menjalankan akun X bertema film Indonesia secara otomatis. Berbeda dari openclaw-bot yang dibangun dari nol, project ini mengeksplorasi cara kerja AI agent framework: bagaimana OpenClaw mengorkestrasikan 7 agent dengan peran berbeda, bagaimana HEARTBEAT.md menggantikan cron untuk scheduling yang laptop-aware, dan bagaimana MiniMax M2.7 dikoneksikan sebagai LLM provider yang 10x lebih murah dari Claude Sonnet untuk use case yang sama.$$,
  $$Bot posting konten film yang hanya mengandalkan satu LLM call per hari tidak bisa belajar dari data performa nyata. Konten yang bagus minggu ini mungkin tidak relevan minggu depan karena tren berubah. Tanpa feedback loop dari engagement data ke strategi konten, bot akan terus posting dengan asumsi yang sama tanpa perbaikan. Selain itu, scheduling berbasis cron di laptop tidak reliable karena job diskip saat laptop tutup.$$,
  $$Membangun sistem 7 agent di OpenClaw dengan tiga kecepatan siklus. Siklus harian: Agent 1 (Scout) riset dari 6 layer sumber (X trending via Playwright, box office FilmIndonesia, RT/IMDb gap, RSS media film, festival, Wikipedia) dengan 3 sub-agent paralel untuk mempersingkat waktu riset dari 14 menit menjadi 7 menit. Agent 2 (Writer) menulis draft dengan 4 mode persona dinamis, lalu menjalankan reflexion loop via llm-task plugin: draft dikritik sendiri dalam format JSON terstruktur (hook_score, authenticity_score, mode_alignment, overall_score), direvisi jika skor < 8, maksimum 3 iterasi. Agent 3 (Publisher) memposting via Tweepy.

Siklus mingguan: Agent 4 (Analyst) scrape metrik tweet sendiri dari X.com UI via Playwright (gratis, bukan X API read yang berbayar). Agent 5 (Director) mengevaluasi data dan memperbarui directives.md dengan instruksi baru per-agent. Siklus bulanan: Agent 6 (Memory Manager) mengkonsolidasi pelajaran ke frozen_rules.md. Agent 7 (Experimenter) merancang A/B experiment baru.

LLM MiniMax M2.7 dikoneksikan ke OpenClaw via openclaw.json dengan endpoint Anthropic-compatible, sehingga semua agent bisa memanggil LLM tanpa perubahan kode.$$,
  ARRAY[
    'Sistem 7 agent dengan tiga kecepatan siklus: harian (eksekusi), mingguan (evaluasi), bulanan (eksperimen).',
    'Reflexion loop di Agent 2: draft dikritik sendiri via llm-task plugin dalam format JSON terstruktur, direvisi jika skor < 8, maksimum 3 iterasi.',
    'Brain state tiga file: brain_state.json (KPI numerik, A/B experiments), directives.md (instruksi aktif per-agent), frozen_rules.md (aturan proven ≥3 minggu).',
    'Parallel sub-agents di Agent 1: 3 sub-agent berjalan bersamaan untuk riset dari sumber berbeda, mempersingkat waktu dari 14 menit menjadi 7 menit.',
    'HEARTBEAT.md scheduling: interval-based (bukan jam fixed) sehingga task tidak diskip saat laptop tutup dan dibuka kembali.',
    'Metrik tweet diambil via Playwright scrape X.com UI (gratis) bukan X API read yang berbayar $100/M token.'
  ],
  'Solo engineer (AI agent system)',
  ARRAY[
    'Python 3',
    'OpenClaw (local AI agent framework)',
    'MiniMax M2.7 (via OpenClaw, Anthropic-compatible endpoint)',
    'Playwright (browser automation)',
    'Tweepy (X API v2)',
    'blogwatcher (OpenClaw skill)',
    'llm-task (OpenClaw plugin)',
    'sessions_spawn (OpenClaw sub-agent)',
    'HEARTBEAT.md (OpenClaw scheduler)',
    'DuckDuckGo',
    'requests',
    'JSON state files'
  ],
  '2026',
  'published',
  FALSE,
  'personal_project',
  ARRAY['backend'],
  ARRAY['backend_engineering', 'architecture'],
  'Solo builder: desain 7 agent dengan peran dan siklus berbeda, reflexion loop, brain state architecture, integrasi MiniMax via OpenClaw, dan Playwright scraping untuk metrik.',
  'Solo project',
  '2026',
  $$Menunjukkan pemahaman cara kerja AI agent framework: bagaimana OpenClaw mengorkestrasikan agent, bagaimana reflexion loop meningkatkan kualitas output secara iteratif, dan bagaimana brain state memungkinkan sistem belajar dari data performa nyata tanpa intervensi manual.$$,
  ARRAY[
    'Reflexion loop via llm-task plugin: Agent 2 mengkritik draftnya sendiri dalam format JSON terstruktur (hook_score, authenticity_score, mode_alignment, overall_score, issues), revisi jika overall_score < 8, force approve di iterasi ke-3.',
    'Parallel sub-agents: Agent 1 spawn 3 sub-agent bersamaan (Playwright X+Letterboxd+Reddit, HTTP scrape FilmIndonesia+RT+IMDb, blogwatcher RSS) untuk mempersingkat riset dari 14 menit menjadi 7 menit.',
    'Brain state tiga file dengan akses berbeda: brain_state.json (machine-readable, ditulis Agent 5 dan 6), directives.md (human-readable Standing Orders, ditulis Agent 5 saja), frozen_rules.md (aturan permanen, ditulis Agent 6 saja).',
    'HEARTBEAT.md interval-based scheduling: task jalan kapanpun akumulasi waktu terpenuhi dan laptop aktif, tidak diskip seperti cron saat laptop tutup.',
    'MiniMax M2.7 dikoneksikan via openclaw.json dengan baseUrl Anthropic-compatible endpoint, sehingga semua agent memanggil LLM dengan interface yang sama tanpa perubahan kode.',
    'Metrik tweet diambil Agent 4 via Playwright scrape tampilan X.com saat login (like/RT/reply dari UI) — gratis, bukan X API read yang berbayar.'
  ],
  $$Tiga kecepatan siklus dengan tanggung jawab yang jelas: Execution Layer (Agent 1-3, harian) menghasilkan konten; Intelligence Layer (Agent 4-5, mingguan) mengevaluasi performa dan memperbarui direktif; Self-Improvement Layer (Agent 6-7, bulanan) mengkonsolidasi pelajaran dan merancang eksperimen baru.

Shared memory via tiga file state: semua agent membaca ketiganya sebelum mulai kerja, tapi hanya Director (Agent 5) yang boleh menulis directives.md dan hanya Memory Manager (Agent 6) yang boleh menulis frozen_rules.md. brain_state.json ditulis keduanya untuk data numerik. Ini mencegah konflik tulis dan menjaga konsistensi state.$$,
  $$Memilih MiniMax M2.7 alih-alih Claude Sonnet karena 10x lebih murah ($0.30/M input vs $3/M) untuk use case yang sama, dan dioptimasi khusus untuk OpenClaw berdasarkan MMClaw benchmark. Konsekuensinya output quality mungkin berbeda untuk task tertentu. HEARTBEAT.md dipilih alih-alih cron karena laptop-based deployment tidak bisa menjamin laptop selalu nyala di jam tertentu; interval-based scheduling lebih toleran terhadap downtime. Playwright scraping untuk metrik dipilih alih-alih X API read karena X API read berbayar $100/M token; scraping UI gratis tapi lebih rapuh terhadap perubahan layout X.com.$$,
  ARRAY[
    'Budget estimasi ~$0.87/bulan: MiniMax M2.7 ~$0.57 + Tweepy post ~$0.30.',
    '7 agent dengan 3 kecepatan siklus: harian, mingguan, bulanan.',
    'Public proof: repo publik di GitHub dengan dokumentasi TRD, ARCHITECTURE.md, dan AGENTS.md.'
  ],
  NULL,
  NULL,
  'https://github.com/nunutech40/mediasosial-bot',
  'public',
  2,
  DATE '2026-04-21',
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
