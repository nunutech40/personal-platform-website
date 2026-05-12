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
    headline = 'Flutter Developer building thoughtful mobile apps with clean architecture, reliable delivery, and practical product sense.',
    subheadline = 'I focus on Flutter for remote mobile roles, with native iOS Swift and Android Kotlin experience, plus enough full-stack range to ship useful products end to end with AI-assisted workflows.',
    primary_cta_text = 'View Work',
    primary_cta_url = '/work',
    secondary_cta_text = 'Contact',
    secondary_cta_url = '/contact',
    active_theme = 'old_web_classic',
    profile_name = 'Nunu Nugraha',
    profile_title = 'Flutter Developer',
    profile_location = 'Indonesia',
    profile_email = 'r.fajarnuraha@gmail.com',
    profile_bio = 'I am a Flutter Developer focused on building mobile apps that are clear, maintainable, and useful. I also have native iOS experience with Swift, Android experience with Kotlin, and enough full-stack range to connect mobile work with backend, web, content, and product workflows.',
    social_links = '{
      "GitHub": "https://github.com/nunutech40",
      "LinkedIn": "https://www.linkedin.com/in/rizka-fajar-nugraha-7998688b/",
      "Email": "mailto:r.fajarnuraha@gmail.com"
    }'::jsonb,
    about_intro = 'I am Nunu Nugraha, a Flutter Developer focused on building mobile apps that feel clear to users and stay maintainable for engineering teams. My main direction right now is Flutter development, especially remote roles where I can contribute to production mobile products.',
    about_focus = 'My strongest lane is Flutter: UI implementation, app architecture, state management, API integration, release workflows, and the product details that make an app pleasant to use. I can also work close to native mobile when needed: Swift for iOS, Kotlin for Android, and full-stack implementation with AI-assisted workflows when a product needs backend, web, CMS, or automation around the mobile app.',
    about_tools = ARRAY[
      'Flutter',
      'Dart',
      'BLoC / Cubit',
      'Go Router',
      'REST API integration',
      'Firebase Auth',
      'Swift / SwiftUI',
      'Kotlin / Android',
      'Elixir / Phoenix LiveView',
      'PostgreSQL',
      'AI-assisted development workflows'
    ],
    about_values = ARRAY[
      'Mobile-first product thinking',
      'Readable architecture over clever code',
      'Small shippable progress',
      'Clear communication with product and design',
      'Learning deeply while still delivering',
      'Useful work that can be shown, written, and improved in public'
    ],
    now_building = 'I am building this personal platform as a home for my Flutter/mobile portfolio, writing, notes, and small digital products. The goal is to make my work easier to inspect by recruiters, partners, and people who care about practical software.',
    now_learning = 'I am going deeper on Flutter development: app architecture, state management, performance, native platform integration, testing, and release quality. I am also sharpening Swift, Kotlin, and AI-assisted full-stack workflows so I can ship complete product slices when needed.',
    now_focus = 'My current focus is finding a remote Flutter Developer role while continuing to build, write, publish, and eventually sell useful technical products from this site.',
    now_updated_at = DATE '2026-05-12',
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
  about_intro,
  about_focus,
  about_tools,
  about_values,
  now_building,
  now_learning,
  now_focus,
  now_updated_at,
  featured_project_ids,
  featured_product_ids,
  inserted_at,
  updated_at
)
SELECT
  '22222222-3333-4444-8555-666666666666',
  'Nunu Nugraha',
  'Flutter Developer building thoughtful mobile apps with clean architecture, reliable delivery, and practical product sense.',
  'I focus on Flutter for remote mobile roles, with native iOS Swift and Android Kotlin experience, plus enough full-stack range to ship useful products end to end with AI-assisted workflows.',
  'View Work',
  '/work',
  'Contact',
  '/contact',
  'old_web_classic',
  'Nunu Nugraha',
  'Flutter Developer',
  'Indonesia',
  'r.fajarnuraha@gmail.com',
  'I am a Flutter Developer focused on building mobile apps that are clear, maintainable, and useful. I also have native iOS experience with Swift, Android experience with Kotlin, and enough full-stack range to connect mobile work with backend, web, content, and product workflows.',
  '{
    "GitHub": "https://github.com/nunutech40",
    "LinkedIn": "https://www.linkedin.com/in/rizka-fajar-nugraha-7998688b/",
    "Email": "mailto:r.fajarnuraha@gmail.com"
  }'::jsonb,
  'I am Nunu Nugraha, a Flutter Developer focused on building mobile apps that feel clear to users and stay maintainable for engineering teams. My main direction right now is Flutter development, especially remote roles where I can contribute to production mobile products.',
  'My strongest lane is Flutter: UI implementation, app architecture, state management, API integration, release workflows, and the product details that make an app pleasant to use. I can also work close to native mobile when needed: Swift for iOS, Kotlin for Android, and full-stack implementation with AI-assisted workflows when a product needs backend, web, CMS, or automation around the mobile app.',
  ARRAY[
    'Flutter',
    'Dart',
    'BLoC / Cubit',
    'Go Router',
    'REST API integration',
    'Firebase Auth',
    'Swift / SwiftUI',
    'Kotlin / Android',
    'Elixir / Phoenix LiveView',
    'PostgreSQL',
    'AI-assisted development workflows'
  ],
  ARRAY[
    'Mobile-first product thinking',
    'Readable architecture over clever code',
    'Small shippable progress',
    'Clear communication with product and design',
    'Learning deeply while still delivering',
    'Useful work that can be shown, written, and improved in public'
  ],
  'I am building this personal platform as a home for my Flutter/mobile portfolio, writing, notes, and small digital products. The goal is to make my work easier to inspect by recruiters, partners, and people who care about practical software.',
  'I am going deeper on Flutter development: app architecture, state management, performance, native platform integration, testing, and release quality. I am also sharpening Swift, Kotlin, and AI-assisted full-stack workflows so I can ship complete product slices when needed.',
  'My current focus is finding a remote Flutter Developer role while continuing to build, write, publish, and eventually sell useful technical products from this site.',
  DATE '2026-05-12',
  '{}',
  '{}',
  NOW(),
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM upsert);
