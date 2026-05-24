# Building Plan - Content Monetization and Commerce

## 0. Purpose

Plan ini menyiapkan monetisasi content dan product tanpa langsung membuat sistem e-commerce besar.

Target:

- Post gratis bisa otomatis menampilkan CTA tips.
- Post tipe tips bisa meminta pembaca memberi tips sebelum/untuk lanjut membaca.
- Post berbayar bisa dikunci sampai pembayaran valid.
- Product digital dan fisik tetap punya jalur checkout yang bisa tumbuh dari payment link manual ke Midtrans proper integration.
- Tidak memaksa multi-login/customer account di fase awal.

## 1. Current State

Saat ini:

- `posts` mendukung title, slug, excerpt, markdown/html content, tags, status, SEO, dan cover image.
- Writing editor direction is Markdown-first with EasyMDE in admin. Keep `content_markdown` as source of truth and use rendered/sanitized `content_html` for public reading.
- `posts.og_image_id` should optionally override `posts.cover_image_id` for social preview cards.
- `posts` mendukung monetization access: `free`, `tips`, dan `paid`.
- `tips` dan `paid` post dikunci sampai order paid/access token valid; bedanya `tips` memakai pilihan nominal dari `tip_amount_options`, sementara `paid` memakai satu `price`.
- `posts.clap_count` menyimpan jumlah clap; list Writing mengurutkan post published dari clap terbanyak lalu tanggal publish.
- `products` mendukung price, currency, product type, delivery type, checkout URL, status, included, FAQ, cover image, `paid_excerpt`, dan `paywall_cta`.
- Product selalu berbayar. Tidak ada mode free/tips untuk product; perbedaannya dari paid post hanya fulfillment/delivery.
- `products` mendukung fulfillment foundation: `fulfillment_type`, `download_media_id`, `requires_shipping`, `payment_provider`, dan `checkout_mode`.
- `orders` dan `access_grants` sudah tersedia untuk post access/tips/product purchase.
- Midtrans Snap redirect dan webhook `/webhooks/midtrans` tersedia. Secret Midtrans dibaca dari env/runtime config.
- Paid order notification email dikirim ke owner saat Midtrans webhook menandai order `paid`.
- `site_settings` menyimpan identity site, profile, email, social links, featured IDs, dan active theme.
- Product checkout MVP memakai `products.checkout_url` sebagai fallback external payment link, tetapi form publik tetap lewat checkout internal supaya siap memakai Midtrans Snap/webhook.

Gap:

- Belum ada email delivery otomatis untuk access link.
- Belum ada halaman download file otomatis untuk product digital.
- Belum ada shipping/courier automation untuk product fisik.
- Belum ada receipt email otomatis untuk buyer.

## 2. Payment Provider Position

Recommended default:

- Product checkout proper: **Midtrans**.
- Manual MVP: `products.checkout_url` tetap boleh dipakai untuk Midtrans Payment Link.
- Tips/donation lightweight: Saweria + Buy Me Coffee links di `site_settings`.

Xendit:

- Not used. User only has Midtrans.
- Do not build Xendit integration unless the user explicitly adds a Xendit account later.
- Admin may keep optional Xendit reference URL fields only as notes/placeholders when explicitly requested. They must not unlock content, create orders, or replace Midtrans.

Catatan implementation:

- Midtrans webhook/HTTP notification harus memakai URL publik, idealnya HTTPS.
- Jangan simpan server key/API key di database content. Pakai env vars/runtime config.

## 3. Global Tip Links

Tambahkan ke `site_settings`:

```txt
buy_me_coffee_url string nullable
saweria_url       string nullable
tips_cta_title    string nullable default "Support this writing"
tips_cta_body     text nullable
```

Public behavior:

- Free post menampilkan CTA di akhir artikel jika minimal satu link tersedia.
- CTA menampilkan Saweria dan/atau Buy Me Coffee.
- Contact/About footer boleh juga memakai link ini jika desain terasa natural.

Admin behavior:

- Site Settings punya panel "Support / Tips".
- URL divalidasi harus `http://` atau `https://`.

## 4. Post Monetization Model

Tambahkan field ke `posts`:

```txt
access_type          string not null default 'free'
price                numeric nullable
currency             string not null default 'IDR'
tip_amount_options   integer[] not null default '{}'
paid_excerpt         text nullable
paywall_cta          text nullable
payment_provider     string nullable
checkout_url         string nullable
```

Existing post fields that monetization must preserve:

```txt
content_markdown     text
content_html         text nullable
editor_type          string default 'markdown'
editor_json          map nullable
cover_image_id       uuid nullable
og_image_id          uuid nullable
seo_title            string nullable
seo_description      text nullable
```

Controlled values:

```txt
access_type:
- free
- tips
- paid

payment_provider:
- manual_link
- midtrans
```

Rules:

- `free`: content full terbuka. End-of-post support CTA injected otomatis.
- `tips`: content dikunci seperti paid post, tetapi buyer memilih nominal dari `tip_amount_options`.
- `paid`: content dikunci setelah excerpt/paywall preview sampai payment valid.
- `paid` wajib punya `price > 0`.
- `tips` wajib punya minimal satu amount option yang dikonfigurasi admin dan buyer wajib memilih salah satunya.
- `free` tidak perlu price.

## 5. Paid Post Without User Login

Bisa, tanpa multi-login.

Recommended Phase 1 approach:

```txt
email + paid access token
```

Flow:

1. User buka paid post.
2. User melihat preview dan form email.
3. User klik pay.
4. System membuat `orders` dengan `kind = post_access`.
5. User bayar via Midtrans Snap/Payment Link.
6. Webhook mengubah order ke `paid`.
7. System mengirim notifikasi email ke owner.
8. System membuat access token.
9. User diarahkan atau dikirimi link:

```txt
/writing/<slug>?access_token=<token>
```

Kelebihan:

- Tidak perlu akun login.
- Cocok untuk one-off paid article.
- Bisa dikirim ulang via email jika nanti email integration dibuat.

Risiko:

- Token bisa dishare. Mitigasi awal: token panjang, bisa expired, dan bisa dibatasi per post/order.
- Tanpa email delivery otomatis, UX awal bisa memakai success page yang menampilkan access link.

Jangan mulai dari multi-login kecuali nanti memang butuh membership/library.

## 6. Orders and Access Tables

Future proper commerce tables:

```txt
orders
- id uuid
- kind string              # post_access, tip, product_purchase
- status string            # pending, paid, failed, expired, refunded
- provider string          # midtrans, manual
- provider_order_id string
- provider_transaction_id string
- buyer_email string
- amount numeric
- currency string
- post_id uuid nullable
- product_id uuid nullable
- metadata map
- paid_at utc_datetime nullable
- fulfillment_status string       # unfulfilled, fulfilled, not_required
- fulfilled_at utc_datetime nullable
- inserted_at / updated_at

access_grants
- id uuid
- order_id uuid
- post_id uuid nullable
- product_id uuid nullable
- buyer_email string
- token_hash string
- expires_at utc_datetime nullable
- used_at utc_datetime nullable
- inserted_at / updated_at
```

Security rules:

- Store token hash, not raw token.
- Only show raw token once in redirect/email.
- Webhook must verify provider signature/status.
- Webhook must be idempotent by provider order ID.
- Owner email notification is sent only on first transition to `paid`.

## 7. Product Commerce Model

Product memakai model checkout yang sejajar dengan paid post, tetapi tanpa `access_type` dan tanpa tips. Semua product harus punya `price > 0` dan currency uppercase 3 huruf.

```txt
products.price numeric not null
products.currency string default 'IDR'
products.paid_excerpt text nullable
products.paywall_cta string nullable
products.fulfillment_type:
- instant_download
- email_delivery
- manual_confirmation
- physical_shipping

products.download_media_id nullable
products.requires_shipping boolean default false
products.payment_provider string default 'midtrans'
products.checkout_mode string default 'midtrans_snap'
```

Product flows:

### Public product checkout

1. User membuka detail product.
2. User melihat summary, price, preview checkout (`paid_excerpt` atau fallback summary/description), dan form email.
3. User submit checkout.
4. System membuat `orders.kind = product_purchase`.
5. Midtrans Snap dipakai jika env tersedia; `checkout_url` manual dipakai sebagai fallback.

Validation:

- Active product dengan `checkout_mode = manual_link` wajib punya `checkout_url`.
- `checkout_mode = midtrans_snap` tidak wajib punya `checkout_url`.
- `physical_shipping` wajib selaras dengan `requires_shipping = true`.

### Digital instant download

1. User pays.
2. Webhook marks order paid.
3. System creates access grant/download token.
4. Success page shows download link.

### Digital/manual delivery

1. User pays.
2. Webhook marks order paid.
3. Admin sees paid order.
4. Admin sends file/access manually.

### Physical product

1. User fills buyer and shipping info.
2. User pays.
3. Webhook marks order paid.
4. Admin fulfills shipment manually first.
5. Shipping automation can come later.

## 8. Public UX Plan

### Free post

End of article:

```txt
Found this useful?
Support future writing via Saweria or Buy Me Coffee.
```

### Tips post

Paywall preview:

```txt
This writing continues after support.
Choose: Rp10.000 / Rp15.000 / Rp20.000
```

Tips post creates an order with `kind = tip`, then unlocks via the same access-token flow as paid posts.

### Paid post

Public preview:

```txt
Title
Excerpt
What you will learn
Price
Pay to unlock
```

After payment:

```txt
/writing/<slug>?access_token=<token>
```

No login required in first proper version.

## 9. Admin UX Plan

### Site Settings

Add panel:

```txt
Support / Tips
- Saweria URL
- Buy Me Coffee URL
- Tips CTA title
- Tips CTA body
```

Optional reference panel when requested:

```txt
Payment Links
- Xendit checkout URL
- Xendit webhook URL
```

These fields are admin notes/placeholders only. Midtrans remains the planned payment provider for paid posts and products.

### Posts

Add panel:

```txt
Monetization
- Access type: Free / Tips / Paid
- Price
- Currency
- Tip amount options
- Paid excerpt
- Paywall CTA
- Payment provider
- Checkout URL (manual link fallback)
```

### Products

Panel:

```txt
Fulfillment
- Fulfillment type
- Download media
- Requires shipping
- Payment provider
- Checkout mode
```

Orders are visible at `/nunu-ops-7f3c/orders`; admin can distinguish paid/unfulfilled/fulfilled.

## 10. Implementation Slices

### Slice 1 - Tip Links and Free Post CTA

Output:

- Add global tip links to `site_settings`.
- Add admin fields.
- Inject CTA into free post detail when links exist.
- Tests for settings validation and public rendering.

Acceptance:

- Free post shows Saweria/Buy Me Coffee CTA.
- CTA does not render if no links are configured.

### Slice 2 - Post Access Type Fields

Output:

- Add `access_type`, `price`, `currency`, `tip_amount_options`, `paid_excerpt`, `paywall_cta`, `payment_provider`, `checkout_url`.
- Admin fields and validation.
- Public post detail branches by access type.

Acceptance:

- Free post stays open.
- Tips post renders a locked preview/paywall with configured amount options.
- Paid post renders preview/paywall instead of full content.

### Slice 3 - Manual Paid Link MVP

Output:

- Use `posts.checkout_url` for paid/tips manual checkout link.
- No webhook yet.
- Admin can manually set paid checkout URL.

Acceptance:

- Paid post can link to external payment page.
- Copy clearly says access is manual until proper integration.

### Slice 4 - Orders and Midtrans Proper Integration

Output:

- `orders` and `access_grants` tables.
- Midtrans transaction creation wrapper.
- Midtrans webhook endpoint.
- Signature/status verification.
- Idempotent order updates.

Acceptance:

- Payment success unlocks paid post via token.
- Tips post payment unlocks via token using a selected configured amount.
- Digital product can generate access token after payment.
- Failed/expired payment does not unlock content.

### Slice 5 - Product Fulfillment

Output:

- Fulfillment fields.
- Admin paid orders list.
- Manual delivery/physical fulfillment states.
- Product admin form distandarkan dengan paid post: price, currency, checkout preview, CTA checkout, provider, checkout mode, checkout URL.
- Product public detail memakai checkout gate yang konsisten dengan paid post.
- Digital download token flow foundation.

Acceptance:

- Product can be instant download, manual delivery, or physical shipping.
- Product selalu paid dan menolak harga `0`.
- Admin can distinguish paid/unfulfilled/fulfilled orders.

## 11. Open Decisions

- Should tips be external-only forever, or move into internal payment flow?
- Should paid post access token expire?
- Do paid post buyers need email receipt in MVP?
- For physical products, is shipping manual first or integrated courier later?

## 12. Recommended Urgent Cut

Do first:

1. Site settings tip links.
2. Free post support CTA.
3. Post `access_type`.
4. Tips post paywall with configured amount options.
5. Paid post preview/paywall with manual checkout URL.

Do later:

1. Email delivery for access links.
2. Product download page/file delivery.
3. Physical shipping automation.
