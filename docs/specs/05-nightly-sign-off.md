# Spec: Nightly Sign Off Sheet

**Priority:** #5 | **Effort:** Low-Medium (~0.5–1 week) | **Viability:** High

---

## Problem

The nightly sign-off sheet is manually assembled every day: copy-paste all next-day invoices from Bakecycle into Excel, remove Bien Cuit accounts, format into Wholesale and Blue Bottle sections, then manually find Joe Sandwich clients and add a third section. This is daily manual work that could be fully automated.

---

## Proposed Solution

A printable report generated from next-day shipments (or order projections if shipments haven't generated yet). Produces:
1. **Main sheet**: All delivery clients in alphabetical order with packing + delivery checkboxes, box/bag counts, and notes
2. **Joe Sandwich section**: Clients receiving Joe Sandwiches flagged separately for special packaging

The report should be printable from any browser (print-friendly CSS or PDF).

---

## Context: Existing Infrastructure

- **Shipments** are already queryable by date: `Shipment.where(bakery: bakery, date: tomorrow).includes(:client, :route, :shipment_items)`
- **Delivery list** (`app/reports/delivery_list_pdf.rb`) is a close cousin — it already generates a per-route client list from shipments. The sign-off sheet is a similar concept but different format and grouping.
- **Routes** could be the segmentation key for Wholesale vs Blue Bottle vs Joe groupings, depending on how routes are named.
- **`product_type: :wholesale_sandwiches`** already exists — Joe Sandwich items can be detected by this product type.

---

## Implementation

### Data questions first (see Open Questions below)

Before building, need to confirm:
1. How Bien Cuit accounts are identified (client name prefix? flag?)
2. How Blue Bottle clients are distinguished from Wholesale (route name? client flag?)
3. Where box/bag counts come from

### New report: `NightlySignOffPdf` or printable HTML

**Recommended: printable HTML** (not PDF) — easier to implement with Turbo/Stimulus, checkboxes are interactive on screen before printing, and it avoids Prawn layout complexity.

Structure:
```
[Date]
WHOLESALE
[checkboxes] [Client Name] [boxes] [bags] [notes]
...
BLUE BOTTLE
[checkboxes] [Client Name] [boxes] [bags] [notes]
...
JOE SANDWICHES
[checkboxes] [Client Name — item details] [boxes] [bags]
```

**Controller**: `NightlySignOffController#show` with a date param (default: tomorrow). Queries shipments for that date, groups by segment.

**Exclusion**: Bien Cuit accounts excluded. If they're identified by client name or a flag, add that filter.

**Joe section**: Filter `ShipmentItem.joins(:product).where(products: { product_type: :wholesale_sandwiches })` within tomorrow's shipments.

### Box/bag counts
Three options (in order of build effort):
1. **Manual columns only** — print blank "boxes" and "bags" columns, staff fills in by hand. Zero implementation cost.
2. **Calculated from item quantities** — requires a `packaging_type` or `boxes_per_unit` field on `Product`. Medium effort.
3. **Per-shipment override** — staff enters box/bag count in Bakecycle when packing. Requires new `ShipmentItem` or `Shipment` fields. Higher effort.

Recommend starting with Option 1 and moving to Option 2 if it's truly needed.

---

## Open Questions for Client

1. **Bien Cuit exclusion**: How are Bien Cuit accounts identified in Bakecycle — by client name starting with "Bien Cuit"? Or is there a flag/category on the client record? Need to know so the filter is reliable.
2. **Wholesale vs Blue Bottle segmentation**: What distinguishes a Blue Bottle client from a Wholesale client in Bakecycle today? Is it the route name, a tag on the client, or something else?
3. **Box and bag counts**: Where do these numbers come from? Are they calculated from items ordered (e.g., X croissants = Y boxes), or does someone manually know how many boxes each client's order fills? This is the biggest unknown in the spec.
4. **Joe Cold Boxes section**: The doc mentions this as a separate section. Is this always the same as "clients ordering wholesale sandwiches," or is it a separate client category?
5. **Interactive vs printable**: Should the sign-off sheet be interactive in the browser (staff checks off on a screen or tablet), or is it always printed on paper? This affects whether we build interactive checkboxes or just print columns.
6. **Timing**: The sheet is for next-day delivery. What time does it need to be ready? If some invoices haven't generated yet by the time it's used, should it fall back to order projections?
7. **Notes**: Should the notes column be pre-populated from any existing order/client note field, or always blank?

---

## Acceptance Criteria

- [ ] Sign-off sheet accessible from navigation (e.g., under Reports or Shipments)
- [ ] Date defaults to tomorrow with a date picker to override
- [ ] Clients listed alphabetically within each segment (Wholesale, Blue Bottle, Joe)
- [ ] Bien Cuit accounts excluded
- [ ] Joe Sandwich section shows only clients with `wholesale_sandwiches` items
- [ ] Boxes and bags columns present (initially blank for manual entry)
- [ ] Page is print-friendly (clean layout, no navigation chrome, page breaks between sections)
- [ ] Delivery date shown prominently at the top
