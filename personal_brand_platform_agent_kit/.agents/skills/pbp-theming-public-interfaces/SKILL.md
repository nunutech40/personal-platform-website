---
name: pbp-theming-public-interfaces
description: Implements replaceable public themes, visual systems, and theme-specific components. Use when styling public pages, adding a theme, or ensuring data remains separate from presentation.
---

# Theming Public Interfaces

## Principle

Same data, different theme. Themes render data; they do not own content.

Use `pbp-coding-elixir-functionally` with this skill when implementing theme registry/fallback functions or shaping the theme data contract.

## When To Use

Use this when:

- implementing `old_web_classic`
- adding future themes
- creating a theme registry
- styling public pages
- building theme previews
- reviewing whether UI content is hardcoded

## Workflow

1. Define the shared theme data contract.
2. Resolve active theme through a registry.
3. Render public pages through the selected theme module/components.
4. Keep navigation and section links available in every theme.
5. Put theme CSS in a theme-specific file when possible.
6. Add fallback behavior for invalid theme keys.

## Elixir Theme Rules

- Theme registry should be a small deterministic module.
- Theme resolution should be a pure function where possible.
- Theme components receive assigns/data contract; they do not query Repo.
- Fallback theme behavior should be explicit and tested.

## old_web_classic Rules

```txt
serif typography
blue underlined links
thin horizontal rules
plain lists
simple image frames
compact readable scale
no duplicated owner name in homepage body if header already shows it
```

## Anti-Patterns

- Hardcoding project/post/product content inside theme modules
- Adding database fields for one visual treatment only
- Hiding navigation for aesthetics
- Building drag-and-drop theme builder in MVP

## Done Checklist

- [ ] Uses shared data contract
- [ ] Theme registry fallback exists
- [ ] Theme modules do not perform side effects
- [ ] Global navigation exists
- [ ] Homepage has start-here links
- [ ] Mobile layout is readable
- [ ] Theme does not duplicate content ownership
