# Documentation Index

Dokumentasi project disusun berdasarkan kategori supaya mudah dibaca manusia dan AI agent.

## Folders

- `product/` — product requirements, scope, target users, MVP goals, commerce direction.
- `technical/` — technical requirements, database direction, Phoenix/PostgreSQL/Midtrans notes.
- `architecture/` — target architecture, Phoenix contexts, Elixir/FP boundaries, route/module structure.
- `planning/` — build plan, AI execution workflow, work packet format, phased implementation slices.
- `standards/` — coding and testing standards for Elixir/Phoenix/PostgreSQL work.
- `design/` — old-web design document and UI reference screenshots.
- `workflows/` — repeatable operational workflows such as commit/push.

## Read Order for Fresh AI Context

```txt
1. ../README.md
2. planning/BUILDING_PLAN_PERSONAL_BRAND_PLATFORM.md
3. architecture/PROJECT_ARCHITECTURE_PERSONAL_BRAND_PLATFORM.md
4. relevant skill in ../personal_brand_platform_agent_kit/.agents/skills
```

## Operational Workflows

- [workflows/PUSH_WORKFLOW.md](workflows/PUSH_WORKFLOW.md)

## Standards

- [standards/CODING_AND_TESTING_STANDARDS.md](standards/CODING_AND_TESTING_STANDARDS.md)

## Agent Usage Examples

Contoh prompt untuk menjalankan skill dan melanjutkan build ada di:

- [../personal_brand_platform_agent_kit/README.md](../personal_brand_platform_agent_kit/README.md)

## Source of Truth

The source of truth lives in this `docs/` folder. The agent kit contains reusable execution skills only, not copies of project documentation.
