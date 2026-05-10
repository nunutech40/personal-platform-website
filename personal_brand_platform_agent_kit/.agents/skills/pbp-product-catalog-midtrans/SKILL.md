---
name: pbp-product-catalog-midtrans
description: Use when building product catalog pages, product admin fields, Buy Now links, Midtrans Payment Link support, or future Midtrans proper commerce planning.
---

# Product Catalog + Midtrans Skill

## Use This Skill When

Use this skill when implementing:

- product list page
- product detail page
- product admin form
- Buy Now button
- `checkout_url`
- Midtrans Payment Link
- future Midtrans proper integration
- commerce schema planning

## MVP Commerce Rule

For MVP, use manual Midtrans Payment Link.

```txt
Product page
↓
Buy Now
↓
products.checkout_url
↓
Midtrans hosted payment page
↓
Manual fulfillment
```

Do not build full checkout, order, webhook, cart, or customer accounts in MVP.

## Product Schema MVP

Required fields:

```txt
title
slug
summary
description
product_type
price
currency
checkout_url
cover_media_id
status
featured
```

## Product Types

Use:

```txt
digital
physical
service
experimental
```

## Product Status

Use:

```txt
draft
active
coming_soon
archived
```

## Public Product List

Show:

```txt
product title
short description
price
status
product type
link to detail
```

## Public Product Detail

Show:

```txt
title
subtitle/summary
description
price
type
preview image
what is included
FAQ
Buy Now
```

## Buy Now Rules

- If product status is `active` and `checkout_url` exists, show `Buy Now`.
- If product is `coming_soon`, show `Coming soon`.
- If `checkout_url` is missing, do not show broken button.
- Open checkout link safely.
- Use `rel="noopener noreferrer"` for external links.

## Admin Product Rules

Admin must be able to edit:

```txt
price
currency
checkout_url
product_type
status
featured
```

Add help text:

```txt
checkout_url can be a Midtrans Payment Link for MVP.
```

## Future Proper Commerce

Only build when requested.

Future tables:

```txt
customers
orders
order_items
payments
product_files
digital_entitlements
shipping_addresses
shipments
```

Future routes:

```txt
/checkout/:product_slug
/payment/success
/payment/pending
/payment/failed
/download/:token
/webhooks/midtrans
```

Future flow:

```txt
Create order
Create Midtrans transaction
Redirect/open Midtrans payment
Receive webhook
Update payment/order status
Grant digital access or start shipping
```

## Anti-Patterns

Do not:

- build cart in MVP
- fake automatic payment confirmation
- store sensitive Midtrans keys in frontend
- expose private download files publicly
- make product pages depend on future order tables

## Task Progress

- [ ] Add product fields
- [ ] Add admin product form
- [ ] Add public product list
- [ ] Add product detail
- [ ] Add Buy Now based on checkout_url
- [ ] Confirm no full commerce was accidentally added
