-- Upsert recruiter-ready homepage/site settings for local development.
--
-- Usage from repository root:
--   /opt/homebrew/opt/postgresql@16/bin/psql -h localhost -U "$(whoami)" -d personal_brand_dev -f scripts/sql/upsert-site-settings.sql
--
-- This intentionally keeps one site_settings row and refreshes the public copy
-- used by the homepage/header after local reset or admin experiments.

WITH existing AS (
  SELECT id
  FROM site_settings
  ORDER BY inserted_at ASC
  LIMIT 1
),
upsert AS (
  UPDATE site_settings
  SET
    site_name = 'Nunu Nugraha',
    headline = 'Software engineer building practical mobile and web products with clear architecture, reliable delivery, and recruiter-readable case studies.',
    subheadline = 'This site is a Phoenix LiveView portfolio CMS: projects, writing, products, media, settings, and themes are managed from one PostgreSQL-backed admin system.',
    primary_cta_text = 'View Work',
    primary_cta_url = '/work',
    secondary_cta_text = 'Contact',
    secondary_cta_url = '/contact',
    active_theme = 'old_web_classic',
    profile_name = 'Nunu Nugraha',
    profile_title = 'Full-stack Software Engineer · Mobile Engineering Lead',
    profile_location = 'Indonesia',
    profile_email = 'r.fajarnugraha@gmail.com',
    profile_bio = 'I build mobile and web systems with an eye for clean architecture, maintainable delivery workflows, and product details that make technical work easy to understand.',
    social_links = '{
      "GitHub": "https://github.com/nunutech40",
      "LinkedIn": "https://www.linkedin.com/in/nunu-nugraha",
      "Email": "mailto:r.fajarnugraha@gmail.com"
    }'::jsonb,
    featured_project_ids = '{}',
    featured_product_ids = '{}',
    updated_at = NOW()
  WHERE id IN (SELECT id FROM existing)
  RETURNING id
)
INSERT INTO site_settings (
  id,
  site_name,
  headline,
  subheadline,
  primary_cta_text,
  primary_cta_url,
  secondary_cta_text,
  secondary_cta_url,
  active_theme,
  profile_name,
  profile_title,
  profile_location,
  profile_email,
  profile_bio,
  social_links,
  featured_project_ids,
  featured_product_ids,
  inserted_at,
  updated_at
)
SELECT
  '22222222-3333-4444-8555-666666666666',
  'Nunu Nugraha',
  'Software engineer building practical mobile and web products with clear architecture, reliable delivery, and recruiter-readable case studies.',
  'This site is a Phoenix LiveView portfolio CMS: projects, writing, products, media, settings, and themes are managed from one PostgreSQL-backed admin system.',
  'View Work',
  '/work',
  'Contact',
  '/contact',
  'old_web_classic',
  'Nunu Nugraha',
  'Full-stack Software Engineer · Mobile Engineering Lead',
  'Indonesia',
  'r.fajarnugraha@gmail.com',
  'I build mobile and web systems with an eye for clean architecture, maintainable delivery workflows, and product details that make technical work easy to understand.',
  '{
    "GitHub": "https://github.com/nunutech40",
    "LinkedIn": "https://www.linkedin.com/in/nunu-nugraha",
    "Email": "mailto:r.fajarnugraha@gmail.com"
  }'::jsonb,
  '{}',
  '{}',
  NOW(),
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM upsert);
