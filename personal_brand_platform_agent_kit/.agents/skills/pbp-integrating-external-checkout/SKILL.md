---
name: pbp-integrating-external-checkout
description: Integrates simple external checkout links before full commerce. Use when adding Buy Now buttons, checkout_url behavior, manual payment instructions, or planning later Midtrans API/webhook upgrades.
---

# Integrating External Checkout

## Principle

Start with external checkout links. Add orders, payments, and webhooks only after the product catalog proves useful.

Use `pbp-coding-elixir-functionally` with this skill when checkout behavior moves from external links to server-created transactions.

## When To Use

Use this when:

- adding `checkout_url`
- rendering Buy Now links
- supporting Midtrans Payment Link
- adding coming soon states
- writing manual fulfillment notes
- planning future proper commerce

## MVP Flow

```txt
Product detail
  ↓
Buy Now
  ↓
products.checkout_url
  ↓
External payment page
  ↓
Manual fulfillment
```

## Buy Now Rules

- Active product with `checkout_url`: show Buy Now.
- Coming soon product: show coming soon/contact state.
- Missing `checkout_url`: do not render a broken checkout button.
- External links should use `target="_blank"` only if UX calls for it, and must include `rel="noopener noreferrer"`.
- Never store Midtrans server keys in frontend code.

## Elixir Boundary Rules

- MVP external checkout only reads `products.checkout_url`.
- Future Midtrans API calls belong in a server-side Commerce integration module.
- Future webhook handlers must be idempotent and return explicit success/error results.
- Product price/name snapshots belong in future order logic, not public theme modules.

## Future Upgrade Path

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

Only add these when explicitly moving from payment links to proper Midtrans integration.

## Done Checklist

- [ ] Product has checkout_url field
- [ ] Buy Now respects product status
- [ ] Missing link state is handled
- [ ] Admin can edit checkout_url
- [ ] No full commerce tables added accidentally
- [ ] Payment secrets remain server-side
- [ ] Future upgrade notes documented
