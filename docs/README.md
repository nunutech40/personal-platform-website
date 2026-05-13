# Documentation Index

Dokumentasi project disusun berdasarkan kategori supaya mudah dibaca manusia dan AI agent.

## Folders

- `product/` — product requirements (PRD), scope, target users, MVP goals, commerce direction.
- `technical/` — technical requirements (TRD), database direction, local setup guide.
- `architecture/` — target architecture, Phoenix contexts, Elixir/FP boundaries, route/module structure.
- `planning/` — build plans, AI execution workflow, work packet format, phased implementation slices.
- `standards/` — coding and testing standards for Elixir/Phoenix/PostgreSQL work.
- `design/` — old-web design document and UI reference screenshots.
- `workflows/` — repeatable operational workflows (push, input project, edit project, fetch context).

## Read Order for Fresh AI Context

```txt
1. ../personal_brand/README.md (project overview, routes, stack)
2. planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md (implementation status, AI workflow)
3. architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md (architecture, contexts, routes)
4. standards/CODING_AND_TESTING_STANDARDS.md (if task touches implementation)
5. technical/LOCAL_SETUP.md (routes, fields, admin workflow)
```

## Operational Workflows

- [workflows/PUSH_WORKFLOW.md](workflows/PUSH_WORKFLOW.md) — commit and push to GitHub
- [workflows/FETCH_PROJECT_CONTEXT_WORKFLOW.md](workflows/FETCH_PROJECT_CONTEXT_WORKFLOW.md) — load context before coding
- [workflows/INPUT_PROJECT_DATA_WORKFLOW.md](workflows/INPUT_PROJECT_DATA_WORKFLOW.md) — input new project via admin
- [workflows/EDIT_PROJECT_DATA_WORKFLOW.md](workflows/EDIT_PROJECT_DATA_WORKFLOW.md) — edit existing project
- [workflows/PROJECT_ARTICULATION_WORKFLOW.md](workflows/PROJECT_ARTICULATION_WORKFLOW.md) — write recruiter-ready copy

## Planning Documents

- [planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md](planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md) — main build plan
- [planning/BUILDING_PLAN_PROJECT_PORTFOLIO_IMPROVEMENT.md](planning/BUILDING_PLAN_PROJECT_PORTFOLIO_IMPROVEMENT.md) — portfolio taxonomy and case study
- [planning/BUILDING_PLAN_UNIFIED_SEARCH.md](planning/BUILDING_PLAN_UNIFIED_SEARCH.md) — unified search feature
- [planning/BUILDING_PLAN_CONTENT_MONETIZATION_AND_COMMERCE.md](planning/BUILDING_PLAN_CONTENT_MONETIZATION_AND_COMMERCE.md) — Midtrans, tips, paid posts
- [planning/QUICK_FIXES_2026_05_11.md](planning/QUICK_FIXES_2026_05_11.md) — admin UX polish

## Standards

- [standards/CODING_AND_TESTING_STANDARDS.md](standards/CODING_AND_TESTING_STANDARDS.md)

## PRD and TRD (.docx)

PRD dan TRD disimpan sebagai `.docx` dan tidak bisa diedit oleh AI agent secara langsung:

- `product/PRD_Personal_Brand_Platform_COMMERCE_READY.docx`
- `technical/TRD_Personal_Brand_Platform_COMMERCE_READY.docx`

**Catatan sinkronisasi (per 2026-05-13):**

PRD/TRD .docx ditulis sebelum implementasi berikut dan belum mencakup:

- Unified search (`/search`) — lihat `planning/BUILDING_PLAN_UNIFIED_SEARCH.md`
- Disciplines taxonomy baru (12 values termasuk `ai_automation`, `cli_tooling`) — lihat `planning/BUILDING_PLAN_PROJECT_PORTFOLIO_IMPROVEMENT.md`
- Load more pagination di `/work`, `/writing`, `/products`
- Filter counts di `/work`
- EasyMDE Markdown editor di admin posts
- Delete confirmation modal (custom Backpex item action)
- Default sort `updated_at DESC` di semua admin resources

Untuk fitur-fitur di atas, gunakan planning docs `.md` sebagai source of truth, bukan PRD/TRD .docx.

## Source of Truth

```txt
Code behavior    → personal_brand/lib/ + personal_brand/test/
Architecture     → docs/architecture/
Implementation   → docs/planning/ (markdown, always up to date)
PRD/TRD          → docs/product/ + docs/technical/ (.docx, may be outdated)
Workflows        → docs/workflows/
Standards        → docs/standards/
```

Jika ada konflik antara .docx dan .md planning docs, **planning docs .md yang benar** karena lebih sering di-update seiring implementasi.
