---
name: pbp-handling-media-assets
description: Handles upload, storage metadata, media pickers, alt text, cover images, galleries, and private/public file boundaries. Use when implementing media features with local disk storage first or S3-compatible storage later.
---

# Handling Media Assets

## Principle

Files live in storage. The database stores metadata and references.

Use `pbp-coding-elixir-functionally` with this skill because upload/storage work is side-effect heavy and needs clear boundaries.

## When To Use

Use this when:

- adding image upload
- integrating local disk or S3-compatible storage
- creating media records
- selecting cover images
- building galleries
- adding alt text
- planning protected product downloads

## Workflow

1. Validate file type and size.
2. Generate safe storage path.
3. Upload file through the server-side media storage adapter.
4. Save metadata in `media` through the Media context.
5. Attach media ID to profile/project/post/product/theme.
6. Render image with alt text and fallback.
7. Handle upload failure cleanly.

## Storage Rule

```txt
MVP public images         -> local disk storage
Future production uploads -> S3-compatible object storage if needed
Future paid product files -> private/protected storage
```

## Security Rules

- Do not expose storage credentials in the browser.
- Do not use public URLs for paid digital downloads.
- Prefer signed URLs/access tokens for future protected files.

## Elixir Integration Rules

- Storage modules return `{:ok, uploaded_file}` or `{:error, reason}`.
- Media context turns successful uploads into `media` records.
- LiveView upload handlers orchestrate but do not own storage details.
- Cleanup partial failures where possible, for example uploaded file succeeded but DB insert failed.

## Done Checklist

- [ ] Upload validation exists
- [ ] Media record saved
- [ ] Storage side effects are wrapped server-side
- [ ] Alt text captured
- [ ] Admin picker can select media
- [ ] Public rendering has fallback
- [ ] Secrets stay server-side
