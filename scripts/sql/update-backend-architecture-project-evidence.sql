-- Update recruiter-facing evidence for Backend Architecture project.
--
-- Usage from repository root:
--   /opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/update-backend-architecture-project-evidence.sql

UPDATE projects
SET
  tech_stack = ARRAY[
    'Elixir',
    'Phoenix LiveView',
    'PostgreSQL',
    'Ecto',
    'Backpex',
    'Phoenix.HTML',
    'Tailwind CSS',
    'daisyUI',
    'Markdown',
    'SQL',
    'Mix',
    'ExUnit'
  ],
  technical_highlights = ARRAY[
    'Designed Ecto schemas and changesets for Project, Post, Product, Media, Tag, Theme, and SiteSetting resources.',
    'Built Content context as the query boundary for published/draft records, slug lookup, featured sorting, and taxonomy filtering.',
    'Configured Backpex LiveResource definitions for admin CRUD, custom field renderers, upload handling, and safer form validation.',
    'Implemented auto-slug generation and duplicate handling for stable public URLs.',
    'Connected project taxonomy, media attachment, site settings, and public LiveView rendering into one CMS-backed flow.'
  ],
  result = ARRAY[
    'Admin CMS can manage seven content types from one Phoenix application.',
    'Public work detail pages can show recruiter-ready role, ownership, technical approach, architecture notes, results, and media.',
    'Content changes no longer require editing static HTML files or touching the database manually.'
  ],
  metrics = ARRAY[
    '213 automated tests passing after latest admin and public detail changes.',
    '7 CMS-backed content types: Project, Post, Product, Media, Tag, Theme, SiteSetting.',
    'Primary public read paths: homepage, /work, /work/:slug, /writing, /products, /about, /now, /contact.'
  ],
  impact_summary = '7 CMS-backed content types, 213 automated tests passing, taxonomy filtering by platform/discipline, and Content context as the single source of truth for public portfolio data.',
  updated_at = NOW()
WHERE slug = 'backend-architecture-personal-brand-platform-cms';
