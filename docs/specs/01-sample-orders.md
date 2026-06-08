# Spec: Sample Orders

**Priority:** #1 | **Effort:** Medium (~1–1.5 weeks) | **Viability:** High

---

## Problem

Bakecycle prevents two invoices for the same client on the same date. When a client has a standing order and also needs a sample tasting, there's no way to track the sample in Bakecycle — so fake "sample" client accounts get created, losing the link to the real client.

---

## Proposed Solution

Add `"sample"` as a third `order_type` alongside `"standing"` and `"temporary"`. Sample orders:
- Bypass the duplicate invoice restriction
- Always generate $0 invoices (no charge to the client)
- Can coexist on the same date as a standing or temporary order for the same client
- Get their own route and delivery instructions
- **Appear on the production run** — the items need to be made, they just aren't billed

---

## Implementation

### Data model
- **`orders.order_type`** is a string column with `inclusion: %w[standing temporary]` validation in `app/models/order.rb`. Add `"sample"` to the inclusion list.
- Add `sample?` predicate (alongside existing `standing?` and `temporary?`).
- No migration needed — the column is already a string.

### Duplicate guard
`ShipmentCreator` (the only place shipments are created) checks `Shipment.where(bakery_id:, client_id:, route_id:, date:, order_id:).first`. Because `order_id` is scoped to the specific order, a sample order with a different `order_id` will naturally create a second shipment. The risk is in UI-level duplicate warnings — confirm where those surface and make them `sample?`-aware.

### Zero-cost invoices
In `ShipmentCreator#shipment_items`, the price per item comes from `item.product_price`. For sample orders, override to `0`:
```ruby
product_price: order.sample? ? 0 : item.product_price
```
Also set `delivery_fee` to `0` if the order is a sample.

### UI changes
- Order form type dropdown: add "Sample" option.
- Orders index / client page: visually distinguish sample orders (label/badge).
- Invoice PDF / email: mark as "Sample — No Charge".
- Duplicate warning (if one exists in the UI): only trigger for standing/temporary, not sample.

### Production run inclusion
`ProductionRunProjection` queries `OrderItem` via the `production_date` scope, which joins through `orders`. Sample order items must be included in this query so they appear on the production run. The `production_date` scope currently has no order-type filter, so this should work automatically — verify after adding the `"sample"` type.

The production run display should label sample items visibly (e.g., "SAMPLE" tag next to the client name) so production staff know the context.

### Report exclusions
Sample shipments should be excluded from:
- Revenue totals
- QuickBooks IIF / invoice CSV exports
- Accounts receivable views
- Daily client totals (billing-facing)

But **included** in:
- Production run (confirmed — items need to be made)
- Delivery lists (driver needs to know about the delivery)
- Daily product totals (production quantity counts)

Check each report that queries `Shipment` and classify it as billing-facing or operations-facing. Add a scope filter only on billing-facing reports (e.g., `joins(:order).where.not(orders: { order_type: "sample" })`).

---

## Open Questions for Client

1. **Production run label**: Sample items appear on the production run — how should they be labeled? "SAMPLE" next to the client name, or a separate section at the bottom of the run?
2. **Delivery list**: Should the sample delivery appear on the route's delivery list alongside regular orders, or in a separate section? The driver needs to know it's a sample tasting (different handling than a regular drop).
3. **Multiple samples same day**: Can a client have two sample orders on the same day (e.g., two different tasting events)? Or is one sample per client per date the rule?
4. **Sample order recurrence**: Are sample orders always one-time (never recurring/standing)? Can we enforce that at the form level?
5. **Invoice emails**: If a client is set to receive invoice emails, should they receive the $0 sample invoice? Or is it internal-only?
6. **Who can create them**: Any staff user, or only managers?

---

## Acceptance Criteria

- [ ] Creating a sample order for a client who has a standing order on the same date succeeds without error
- [ ] The sample invoice shows $0 for all line items and delivery fee
- [ ] The existing duplicate-invoice warning still fires for standing/temporary duplicates
- [ ] Sample items appear on the production run with a visible "SAMPLE" label
- [ ] Sample shipments appear on delivery lists
- [ ] Sample shipments are excluded from revenue, billing, and accounts receivable reports
- [ ] Sample orders are visually distinct in the orders list and invoice view
