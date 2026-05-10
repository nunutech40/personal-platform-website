---
name: pbp-media-storage
description: Use when implementing media upload, Supabase Storage integration, media records, cover images, galleries, and alt text.
---

# Media Storage Skill

## Use This Skill When

Use this skill when implementing:

- image upload
- file upload
- Supabase Storage integration
- media library
- cover image selection
- gallery images
- product files planning

## Storage Architecture

Use Supabase Storage for actual files.

Use `media` table for metadata.

```txt
Supabase Storage
  └── stores file

media table
  └── stores file metadata and public/private URL
```

## media Fields

```txt
id
file_name
file_url
storage_path
mime_type
size_bytes
alt_text
created_at
updated_at
```

## Bucket Suggestion

```txt
public-media
```

For MVP, use public images.

Future digital products should use private/protected storage, not public media.

## Upload Rules

- Validate file size.
- Validate MIME type.
- Generate safe storage path.
- Store metadata after successful upload.
- Add alt_text.
- Do not store service role key in browser.
- Handle upload failure gracefully.

## Usage Rules

Use media for:

```txt
profile avatar
project cover
project gallery
post cover
product cover
product gallery
theme preview
```

Do not hardcode image URLs in templates except seed/demo data.

## Media Picker

Admin media picker should allow:

```txt
upload new file
select existing media
preview selected media
edit alt text
```

## Task Progress

- [ ] Setup Supabase Storage config
- [ ] Create media schema
- [ ] Implement upload service
- [ ] Implement admin media page
- [ ] Attach media to content forms
- [ ] Render images with alt text
