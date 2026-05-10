---
name: pbp-theme-system
description: Use when implementing or extending the theme system, theme registry, theme data contract, active_theme, and theme-specific UI for the Personal Brand Platform.
---

# Theme System Skill

## Core Concept

```txt
Same data.
Different theme.
```

The public website can change visual style without changing content.

## Use This Skill When

Use this skill when:

- implementing active_theme
- building theme registry
- creating a new theme
- rendering homepage based on theme
- adding theme preview
- changing old_web_classic UI
- defining shared theme data

## Theme Data Contract

Every theme must accept the same data:

```elixir
%{
  profile: profile,
  site_settings: settings,
  projects: projects,
  posts: posts,
  products: products,
  tags: tags,
  media: media
}
```

Do not create theme-specific database fields unless absolutely necessary.

Current prototype note:

```txt
The static prototype stores active_theme in localStorage and keeps dummy data in src/app.js.
This is only for local UI validation.
Final Phoenix implementation must read/write active_theme through site_settings.
```

## site_settings Fields

Theme system depends on:

```txt
active_theme
active_homepage_variant
featured_project_ids
featured_post_ids
featured_product_ids
headline
subheadline
primary_cta_text
primary_cta_url
secondary_cta_text
secondary_cta_url
social_links
```

## Theme Registry

Create a central registry.

Example:

```elixir
%{
  "old_web_classic" => PersonalBrandWeb.Themes.OldWebClassic,
  "simple" => PersonalBrandWeb.Themes.Simple,
  "us_builder" => PersonalBrandWeb.Themes.USBuilder,
  "premium_dark" => PersonalBrandWeb.Themes.PremiumDark
}
```

## MVP Rule

Implement only:

```txt
old_web_classic
```

Other themes can exist as placeholders.

## Adding a New Theme

When adding a theme:

1. Add it to `themes` table.
2. Add it to `ThemeRegistry`.
3. Create theme module.
4. Implement all required public page renderers or shared components.
5. Ensure it consumes the standard data contract.
6. Add preview in admin.
7. Do not modify content tables.

## Required Theme Pages

A complete theme must support:

```txt
home
work list
work detail
writing list
writing detail
products list
product detail
about
now
contact
```

## Old Web Classic Rules

```txt
white background
black serif text
blue underlined links
thin horizontal rules
simple lists
minimal JS
minimal CSS
clear nav
human/raw feeling
```

## UX Rules

Even if the theme is old-school, navigation must be clear.

Every homepage must include:

```txt
global nav
start here links
view all work
view all writing
view all products
footer nav
```

## Anti-Patterns

Do not:

- hardcode content in theme templates
- create a new data model per theme
- hide navigation for aesthetics
- make theme switching require deployment
- create a visual page builder for MVP

## Task Progress

- [ ] Load active_theme from site_settings
- [ ] Resolve theme module
- [ ] Load theme data contract
- [ ] Render page with theme
- [ ] Verify nav paths exist
- [ ] Verify content is not duplicated
