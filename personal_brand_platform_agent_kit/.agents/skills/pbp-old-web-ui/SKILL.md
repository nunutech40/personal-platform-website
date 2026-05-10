---
name: pbp-old-web-ui
description: Use when implementing the old_web_classic theme, retro HTML-style UI, CSS, typography, layout, and responsive behavior.
---

# Old Web Classic UI Skill

## Use This Skill When

Use this skill when building:

- old_web_classic theme
- public page templates
- old-school CSS
- retro HTML-inspired layout
- content presentation
- responsive old web UI

## Visual Direction

The site should feel like a thoughtful old personal website, not a broken website.

Keywords:

```txt
old internet
plain HTML energy
serif typography
blue links
thin rules
minimal CSS
personal
human
readable
quietly distinctive
```

## Design Rules

Use:

```txt
white background
black text
serif headings
blue underlined links
horizontal rules
plain bullet lists
simple image borders
large readable type
content-first layout
```

Current prototype correction:

```txt
Do not duplicate the owner name in the homepage body when the header already shows it.
Keep old_web_classic type compact enough to resemble the reference mockups.
Use link-style CTAs for old_web_classic unless a plain HTML button is explicitly needed.
```

Avoid:

```txt
glassmorphism
gradients
glow effects
heavy cards
animated hero sections
fake SaaS landing page vibe
over-polished AI slop
```

## Layout Rules

### Page width

Use a readable max width.

```css
max-width: 1120px;
margin: 0 auto;
padding: 32px;
```

### Typography

Use system serif fonts.

```css
font-family: Georgia, "Times New Roman", Times, serif;
```

### Links

Keep default web feeling:

```css
a {
  color: #0000ee;
  text-decoration: underline;
}
```

### Rules

Use thin separators:

```css
hr {
  border: 0;
  border-top: 1px solid #222;
}
```

## Required Public Navigation

Every public page must have:

```txt
Home | Work | Writing | Products | About | Now
```

Social/contact links may be separate:

```txt
GitHub | X | LinkedIn | Email
```

## Homepage Layout

The homepage should include:

```txt
Name
Subtitle
Navigation
Social links
Intro
Start here
Featured Work
Recent Writing
Products
Now
Footer
```

## Start Here Section

Add this to avoid dead-end homepage UX:

```txt
Start here:
- View my work
- Read my writing
- See products
- Learn about me
```

## Image Usage

Images should be:

```txt
bordered
simple
right-aligned on desktop when useful
stacked on mobile
not too glossy
```

## Mobile Rules

On small screens:

```txt
single column
large enough links
image full width
nav wraps naturally
no horizontal scroll
```

## Accessibility Rules

- Use semantic headings.
- Use real links.
- Use alt text.
- Keep color contrast high.
- Do not use tiny font sizes.
- Ensure keyboard navigation works.

## Task Progress

- [ ] Use old_web_classic CSS
- [ ] Keep content readable
- [ ] Add global nav
- [ ] Add footer nav
- [ ] Add start here links on homepage
- [ ] Test mobile layout
- [ ] Keep aesthetic raw but intentional
