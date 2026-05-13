-- Insert: X Autoposting Bot (Manual/Latihan)
-- Project latihan workflow automation tanpa platform, pakai Python + Claude CLI + cron
INSERT INTO projects (
  id, title, slug, summary, description, problem, solution,
  architecture_notes, tradeoffs, result, role, ownership, team_size,
  project_type, platforms, disciplines, tech_stack, year, duration,
  sort_date, status, featured, sort_order, impact_summary,
  technical_highlights, metrics, case_study_visibility,
  company, client, demo_url, github_url, app_store_url,
  inserted_at, updated_at
) VALUES (
  gen_random_uuid(),
  'X Autoposting Bot — Manual Workflow Automation',
  'x-autoposting-bot-manual',
  'Bot otomasi posting X (Twitter) yang dibangun dari nol tanpa platform middleware, sebagai latihan membangun workflow automation end-to-end.',
  'Project latihan untuk memahami cara kerja automated content pipeline dari riset trending, generate konten via LLM, sampai posting ke X API. Dibangun tanpa framework middleware seperti OpenClaw — semua orchestration ditulis manual di Python dengan scheduler, retry logic, dan Telegram alerting. Bot berjalan di VPS IDCloudHost dan dikelola via PM2.',
  'Ingin memahami secara mendalam bagaimana workflow automation bekerja: dari scheduling, API integration, content generation via LLM, sampai deployment di VPS. Kebanyakan developer langsung pakai platform jadi tanpa memahami mekanisme di baliknya. Project ini sengaja dibangun manual supaya paham setiap layer: scheduler, retry, rate limit, prompt engineering, dan monitoring.',
  'Membangun Python scheduler (library schedule) yang mengorkestrasi 3 posting terjadwal per hari plus 12 posting spontan per minggu yang didistribusikan acak. Konten di-generate via Claude CLI dengan prompt engineering berlapis: persona, mode konten (9 variasi), dan universal output rules. Riset trending diambil dari Google News lalu di-scoring berdasarkan neuroscience hook (Amygdala, Loss Aversion, RAS Specificity, Curiosity Gap). Posting ke X via Tweepy API v2.

Sistem juga menjalankan A/B testing antara model Original (prompt terstruktur 9 mode) dan model Challenger (prompt copywriter bebas) untuk membandingkan engagement. Laporan harian dan breakdown A/B dikirim otomatis ke Telegram.',
  'Arsitektur sistem dibagi menjadi 3 layer:
1. Orchestration layer: worker.py sebagai scheduler utama yang mengatur jadwal tetap dan spontan, guard anti-duplikat, dan jeda acak supaya posting tidak prediktif.
2. Skills layer: modul terpisah untuk riset (Google News + hook scoring), tweet writing (prompt + validation + retry), artikel thread, dan SEO page builder.
3. Integration layer: core modules untuk Twitter API (Tweepy), Telegram alerting, logging, dan deployment script (rsync ke VPS).',
  'Keputusan teknis yang sengaja diambil:
1. Pakai Claude CLI langsung via subprocess, bukan SDK — lebih simpel untuk single-call pattern dan tidak perlu manage session. Trade-off: tidak bisa streaming, tapi untuk tweet generation tidak perlu.
2. Scheduling pakai library schedule (Python) bukan cron — supaya guard logic (anti-duplikat, kuota mingguan) bisa hidup di memory yang sama dengan scheduler.
3. Tidak pakai database — state disimpan di JSON files (daily_log, kuota_spontan). Cukup untuk skala bot personal, dan deployment jadi lebih ringan.
4. A/B testing dilakukan dengan memisahkan prompt model, bukan memisahkan akun. Satu persona, dua cara nulis — hasilnya bisa dibandingkan di feed yang sama.',
  ARRAY['Bot berjalan stabil di VPS tanpa intervensi manual selama berminggu-minggu', 'Memahami end-to-end workflow automation: scheduling, LLM integration, API posting, monitoring', 'A/B testing model prompt menghasilkan data perbandingan engagement yang actionable', 'Telegram alerting memastikan awareness tanpa harus SSH ke server'],
  'Automation Engineer',
  'Solo builder end-to-end: arsitektur, prompt engineering, deployment, monitoring',
  'Solo',
  'personal_project',
  ARRAY['backend'],
  ARRAY['backend_engineering', 'architecture'],
  ARRAY['Python', 'Claude CLI (Anthropic)', 'Tweepy (X/Twitter API v2)', 'schedule (Python scheduler)', 'BeautifulSoup4', 'DuckDuckGo Search', 'PM2 (process manager)', 'Telegram Bot API', 'rsync', 'VPS IDCloudHost', 'JSON file-based state'],
  '2026',
  'Apr 2026 - sekarang',
  '2026-04-01',
  'published',
  false,
  14,
  'Latihan membangun automated content pipeline dari nol — memahami setiap layer tanpa bergantung platform middleware.',
  ARRAY['Neuroscience-based hook scoring (Amygdala, Loss Aversion, RAS, Curiosity Gap, Practical Value) untuk ranking trending news', 'A/B testing dua model prompt (Original 9-mode vs Challenger copywriter) dalam satu persona', 'Guard system anti-duplikat posting spontan yang survive restart', 'Prompt trimming untuk optimasi token: strip whitespace, BOM, dan multi-newline sebelum kirim ke Claude', 'Tweet validation guardian yang menolak output meta Claude (balik nanya/klarifikasi) dengan auto-retry 3x'],
  ARRAY['3 posting terjadwal + 1-2 spontan per hari berjalan konsisten', '9 mode konten yang dirotasi mingguan via WEEKLY_MODE_MATRIX', 'Bot uptime stabil di VPS tanpa crash selama operasi normal'],
  'public',
  'Personal Project',
  NULL,
  NULL,
  'https://github.com/nunutech40/mediasosial-bot',
  NULL,
  NOW(), NOW()
);

-- Insert: Film-X-Bot (OpenClaw Platform Implementation)
-- Implementasi OpenClaw framework beneran dengan multi-agent architecture + MiniMax LLM
INSERT INTO projects (
  id, title, slug, summary, description, problem, solution,
  architecture_notes, tradeoffs, result, role, ownership, team_size,
  project_type, platforms, disciplines, tech_stack, year, duration,
  sort_date, status, featured, sort_order, impact_summary,
  technical_highlights, metrics, case_study_visibility,
  company, client, demo_url, github_url, app_store_url,
  inserted_at, updated_at
) VALUES (
  gen_random_uuid(),
  'Film-X-Bot — Multi-Agent Content System (OpenClaw)',
  'film-x-bot-openclaw',
  'Sistem multi-agent self-improving untuk konten film di X, dibangun di atas OpenClaw framework dengan MiniMax LLM dan arsitektur 7 agent yang bisa belajar dari performa sendiri.',
  'Implementasi nyata OpenClaw platform sebagai middleware AI di lokal. Sistem ini bukan bot biasa yang posting berulang — ini adalah virtual content agency dengan 7 agent yang masing-masing punya tanggung jawab spesifik: riset, menulis, posting, analisis, evaluasi, konsolidasi memori, dan eksperimen. Niche konten: opini film, review, dan industri perfilman Indonesia. Berjalan di lokal dengan OpenClaw gateway yang terhubung ke MiniMax M2.7 sebagai LLM utama.',
  'Bot konten biasa tidak bisa improve sendiri — performanya stagnan karena tidak ada feedback loop dari data engagement nyata. Selain itu, menjalankan multi-agent system biasanya butuh infrastruktur kompleks (LangGraph, CrewAI, cloud orchestration). Tantangannya: bagaimana membangun sistem yang self-improving, multi-agent, tapi bisa jalan di lokal tanpa cloud dependency berat?',
  'Menggunakan OpenClaw framework sebagai middleware layer antara agent scripts dan LLM provider. OpenClaw gateway berjalan di lokal (port 18790) dan menangani routing ke MiniMax M2.7 via Anthropic-compatible API. Setiap agent adalah Python script independen yang membaca/menulis ke shared state folder.

Sistem bekerja dalam 3 siklus: Harian (Scout → Writer dengan Reflexion Loop → Publisher), Mingguan (Analyst scrape metrik → Director update directives), dan Bulanan (Memory Manager konsolidasi frozen rules → Experimenter rancang A/B test baru). Writer menggunakan Reflexion Loop: draft → self-critique (skor 1-10) → revise sampai score >= 8 atau max 3 iterasi.',
  'Arsitektur multi-agent dengan shared state pattern:
1. OpenClaw Gateway sebagai middleware: menangani model routing, environment injection, heartbeat scheduling, dan Telegram channel. Agent tidak perlu manage API key atau connection — gateway yang handle.
2. Shared state via JSON files di folder state/: brain_state.json (KPI numerik, machine-readable), directives.md (instruksi per-agent, human-readable), frozen_rules.md (aturan permanen dari data 3+ minggu).
3. Heartbeat controller mengorkestrasi task berdasarkan interval: 4h untuk drafting pipeline, 168h untuk weekly review, 720h untuk monthly memory consolidation.
4. Skills sebagai modular tools: Playwright untuk scraping (X trending, Letterboxd, film sites), xurl untuk posting, DuckDuckGo untuk riset, dan berbagai intel modules (IMDB, Rotten Tomatoes, YouTube, Reddit).',
  'Keputusan teknis yang sengaja diambil:
1. Pakai MiniMax M2.7 sebagai LLM utama, bukan Claude/GPT — cost lebih rendah ($0.30/1M input, $1.20/1M output) dengan context window 200K dan reasoning capability. Trade-off: kurang mature dibanding Claude untuk nuanced writing, tapi cukup untuk konten opini film.
2. OpenClaw di lokal, bukan cloud deployment — supaya bisa eksperimen bebas tanpa biaya server. Trade-off: bot hanya jalan saat mesin lokal hidup, tapi untuk fase eksperimen ini acceptable.
3. Reflexion Loop di Writer agent — setiap draft di-critique sendiri sebelum posting. Trade-off: 2-3x LLM call per konten, tapi kualitas output jauh lebih konsisten.
4. State berbasis file (JSON + Markdown), bukan database — lebih mudah di-inspect manual dan di-version control. Trade-off: tidak cocok untuk concurrent writes, tapi dengan 1 agent aktif per waktu ini bukan masalah.
5. 4 persona mode (Honest Friend, Contrarian Analyst, Hidden Gems Curator, Industry Observer) yang dirotasi berdasarkan data performa — bukan fixed persona.',
  ARRAY['Sistem multi-agent yang bisa self-improve berdasarkan data engagement nyata', 'Reflexion Loop menghasilkan konten dengan kualitas lebih konsisten dibanding single-shot generation', 'Weekly directive update membuat strategi konten adaptif tanpa intervensi manual', 'Arsitektur modular: bisa tambah intel source baru (Letterboxd, IMDB, RT) tanpa ubah core logic'],
  'AI Systems Engineer',
  'Solo builder: arsitektur multi-agent, OpenClaw configuration, skill development, prompt engineering, deployment',
  'Solo',
  'personal_project',
  ARRAY['backend'],
  ARRAY['backend_engineering', 'architecture'],
  ARRAY['Python', 'OpenClaw Framework (local gateway)', 'MiniMax M2.7 (LLM via Anthropic-compatible API)', 'Tweepy (X/Twitter API v2)', 'Playwright (browser automation + scraping)', 'Telegram Bot API', 'DuckDuckGo Search', 'JSON/Markdown shared state', 'Heartbeat scheduler (OpenClaw built-in)', 'PIL/Pillow (image processing)', 'BeautifulSoup4'],
  '2026',
  'Apr 2026 - sekarang',
  '2026-04-15',
  'published',
  false,
  13,
  'Implementasi nyata multi-agent AI system yang self-improving — dari arsitektur sampai operasional, tanpa cloud dependency.',
  ARRAY['7-agent architecture dengan separation of concerns: Scout, Writer, Publisher, Analyst, Director, Memory Manager, Experimenter', 'Reflexion Loop: draft → self-critique → revise (max 3 iterasi, threshold score 8/10)', 'Brain State pattern: shared memory yang dibaca semua agent tapi hanya ditulis oleh Director dan Memory Manager', '3 siklus feedback: harian (execution), mingguan (intelligence/evaluation), bulanan (self-improvement/experimentation)', 'OpenClaw heartbeat controller untuk task orchestration berbasis interval tanpa cron', 'Modular intel skills: Playwright scraping untuk X trending, Letterboxd, IMDB, Rotten Tomatoes, Reddit, YouTube'],
  ARRAY['7 agent beroperasi dalam 3 siklus otomatis (harian/mingguan/bulanan)', '30+ modular skills/tools tersedia untuk riset dan content generation', 'Konten di-publish otomatis ke X pada prime hours berdasarkan data engagement'],
  'public',
  'Personal Project',
  NULL,
  NULL,
  'https://github.com/nunutech40/mediasosial-bot',
  NULL,
  NOW(), NOW()
);
