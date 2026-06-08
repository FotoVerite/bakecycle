# Spec: Cancellations (Individual + Bulk)

**Priority:** #3 | **Effort:** Low-Medium (~0.5–1 week) | **Viability:** High

---

## Problem

Cancelling an order requires opening each client individually, placing a zeroed-out temporary order, and manually deleting any generated invoice for that date. For large-volume closures (holidays, store shutdowns) this is extremely time-consuming with many clients to cancel one-by-one.

---

## Proposed Solution

A dedicated cancellation page that:
1. Lets staff select one or more clients and a date
2. Automatically places a zeroed-out temporary order for each selected client
3. Automatically deletes any invoices (shipments) already generated for that client/date
4. Optionally: adds a visible "cancelled" marker so the cancellation is auditable

---

## How Cancellations Work Today (No New Model Needed)

A zeroed temporary order already serves as a cancellation — it overrides a standing order and creates a $0 invoice (or no invoice if all items are 0 and there's no delivery fee). The new feature is purely a UI automation of this existing pattern.

The `ShipmentCreator` already handles the "temporary overrides standing" logic. For the cancellation case we just need to:
1. Create a `temporary` order with all quantities set to 0 (if one doesn't already exist for that date)
2. Destroy any existing shipments for that client/date

---

## Implementation

### New controller: `CancellationsController`
- `GET /cancellations/new` — select clients + date form
- `POST /cancellations` — process

### Service: `OrderCancellationService`
```ruby
OrderCancellationService.new(bakery, client_ids, date).cancel!
```
For each client:
1. Find or create a `temporary` order covering `date` with all items at quantity 0
2. `Shipment.where(bakery: bakery, client: client, date: date).destroy_all`
3. Return a result summary (cancelled / skipped / error per client)

**Edge cases to handle:**
- Client already has a zeroed temp order for that date → skip (idempotent)
- Client has a non-zeroed temporary order → **warn** and ask: update to zero or skip? (don't silently overwrite)
- Client has no standing order for that date (e.g., doesn't deliver on that day of week) → skip with note

### UI — client multi-select
Use the existing Stimulus filter pattern (same as `clients-table` controller). Clients list with checkboxes, filterable by name or route. "Select all on route" button would be high value for bulk route closures.

### Confirmation step
Before processing: show a summary table — "These X clients will have their [date] orders cancelled. Y clients already have a cancellation. Z clients have no order on this date." Require a confirm button to proceed.

### Result page
After processing: show success/skip/error per client. Link back to orders or production run for that date to verify.

---

## Open Questions for Client

1. **What triggers bulk cancellations?** Is it always a specific route closing, or can it be any subset of clients? Knowing this shapes whether a "select by route" shortcut is worth building.
2. **Existing non-zeroed temporary orders**: If a client already has a temporary order for that date (e.g., they reduced their order but didn't cancel), do you want to: (a) always zero it out, (b) warn and ask, or (c) skip it?
3. **Undo / re-activate**: After a bulk cancellation, do you need a way to undo it (restore the standing order)? Or is re-entering the order manually acceptable?
4. **Client notification**: Some clients are set to receive invoice emails when shipments are generated. Should cancellation suppress those emails, or send a cancellation confirmation?
5. **Visibility in reports**: Should cancelled dates show up in daily totals as explicit "0 — cancelled" rows, or just not appear at all?
6. **Recurring holidays**: Is this a one-off tool or would it be useful to schedule recurring closures (e.g., "cancel all orders every Thanksgiving")?

---

## Acceptance Criteria

- [ ] Staff can select multiple clients + a date and cancel in one action
- [ ] Zeroed temporary orders are created for each selected client that has an active order on that date
- [ ] Existing shipments for that client/date are destroyed
- [ ] Clients with no active order on the date are skipped with a visible note
- [ ] Clients with an existing non-zeroed temporary order surface a warning (not silently overwritten)
- [ ] A confirmation step is shown before any data is modified
- [ ] A result summary is shown after processing
