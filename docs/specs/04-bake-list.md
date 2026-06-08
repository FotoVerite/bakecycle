# Spec: Bake List

**Priority:** #4 (Highest Difficulty + Highest Importance) | **Effort:** High (~2–3 weeks) | **Viability:** Medium-High (phased)

---

## Problem

The bake list is assembled manually every day from multiple Bakecycle reports (1-day and 2-day Daily Totals, 1-day and 2-day Pack Lists) plus a Google Sheet with formulas. The process requires copy-pasting from multiple sources, manual entry of retail numbers from Pack Lists, and produces four outputs: Retail Bake, Wholesale Bake, Pull/Prep List, and Viennoiserie Pick.

---

## What the Bake List Needs to Show

### Retail Bake List
Items baked the **morning of delivery** (lead = 0 days). Shows:
- Item name and total quantity
- Individual location pars (Smith, Franklin) in separate columns

### Wholesale Bake List
Items baked the **day before delivery** (lead = 1 day). Shows:
- Item name and total quantity
- Columns for staff to record how many were short or extra

### Pull / Prep List
Items that are **pulled from storage** rather than baked fresh. Shows:
- Item name, quantity
- Tray count (where applicable)

### Viennoiserie Pick
A separate tray-count view of viennoiserie items for the pick. Shows:
- Item name
- Wholesale Bake tray/piece count
- Retail Bake tray/piece count
- Total tray/piece count
- Blank check-off column

---

## Context: Existing Data Model

- **`product_type` enum** on `Product`: includes `vienoisserie` (note: typo in the codebase). The Viennoiserie Pick can be filtered by this type. Other relevant types: `bread`, `cookie`, `tart_and_desert`, `wholesale_sandwiches`.
- **`ProductionRunProjection`** queries `OrderItem` for any date directly — no pre-generated shipment needed. The Bake List can use this same engine.
- **`tray_count`** does not exist yet (added in Spec #2).

### New fields required

| Field | Table | Type | Description |
|-------|-------|------|-------------|
| `tray_count` | `products` | integer, nullable | Pieces per tray (shared with Spec #2) |
| `bake_lead_days` | `products` | integer, default 1 | 0 = retail (morning of), 1 = wholesale (day before), null = pull/prep |
| `on_pull_list` | `products` | boolean, default false | Whether item appears on the pull list |

> **Note on `bake_lead_days`**: This is separate from `total_lead_days` (which controls when the production run starts). A Miche has `total_lead_days = 4` but its bake day is still 1 day before delivery. These are independent concepts.

---

## Implementation

### Phase 1 — Migrations + product form (prerequisite)
1. Add `tray_count` integer column (nullable) — shared with Spec #2
2. Add `bake_lead_days` integer column (default: 1, nullable)
3. Add `on_pull_list` boolean column (default: false)
4. Update product form to expose all three fields
5. Update existing products with correct values (data entry task for client)

### Phase 2 — Bake List report engine
New service: `BakeListData.new(bakery, bake_date)`

For a given `bake_date`:
- **Retail items**: delivery_date = `bake_date` (bake_lead_days = 0) → query `ProductionRunProjection.new(bakery, bake_date)` filtering for products with `bake_lead_days = 0`
- **Wholesale items**: delivery_date = `bake_date + 1` → query `ProductionRunProjection.new(bakery, bake_date + 1)` filtering for products with `bake_lead_days = 1`
- **Pull list**: filter by `on_pull_list = true`
- **Viennoiserie Pick**: cross-reference retail + wholesale results, filter by `product_type = :vienoisserie`

Tray math helper: `(total_qty / tray_count).floor` trays + `total_qty % tray_count` pieces.

### Phase 3 — PDF/XLSX output
New `BakeListXlsx` or `BakeListPdf` class with four sections (sheets or pages):
- Retail Bake (with par columns)
- Wholesale Bake (with short/extra columns)
- Pull/Prep List
- Viennoiserie Pick

Wire through existing `FileExport` + background job pattern.

### Phase 4 — Per-location pars (Retail Bake only)
The Retail Bake shows per-location pars (Smith, Franklin). Two options:
- **Simple**: Two nullable integer columns on `products` (`smith_par`, `franklin_par`) — fast to build, brittle if locations change.
- **Flexible**: New `product_location_pars` join table (product_id, location_name, par_count) — more robust, slightly more work.

Recommend the simple approach first; migrate to a join table if more locations are ever needed.

---

## Open Questions for Client

1. **Bake lead days by product**: Does every product have a fixed bake lead time (always retail or always wholesale), or can the same product appear on both depending on the order? E.g., can Croissants ever be retail AND wholesale?
2. **Pull list vs bake list**: What determines if an item is on the pull list? Is it a product-level flag, or does it depend on which list it's being prepared for?
3. **Miche and long-lead items**: Miche has a 4-day production lead time but we're told it's baked day-before. Should `bake_lead_days = 1` on Miche regardless of `total_lead_days`? Confirm this is correct.
4. **Location pars**: Are Smith and Franklin the only two locations that need individual pars on the Retail Bake? Are there others (Blue Bottle locations, Joe locations)?
5. **Do pars change?** Are pars static, or do they change seasonally / weekly? If they change often, the two-column approach won't scale.
6. **Viennoiserie Pick scope**: Is the Viennoiserie Pick only `vienoisserie` product type items, or does it include other tray-counted items (e.g., cookies)?
7. **Sheet 2 (production pars)**: The doc mentions "Sheet 2 of the Bakelist remains as is and is used by BOH as a pars sheet." Is that something we need to generate in Bakecycle, or does it stay as the existing Google Sheet?
8. **Date navigation**: Should the bake list always be "for today's bake date" with a date picker, or should it be generated on demand for a specific date from the reports page?
9. **Wholesale bake short/extra columns**: Are these filled in manually by staff, or should Bakecycle track actuals? (If manual, these are just blank columns on the printed sheet — no new data model needed.)

---

## Acceptance Criteria

- [ ] Products have `bake_lead_days`, `tray_count`, and `on_pull_list` fields editable in the product form
- [ ] Bake List report generates for a given date with four sections: Retail Bake, Wholesale Bake, Pull List, Viennoiserie Pick
- [ ] Retail Bake shows per-location par columns (Smith, Franklin)
- [ ] Wholesale Bake shows blank short/extra columns for manual staff entry
- [ ] Viennoiserie Pick shows tray + piece counts per item and a total column
- [ ] Pull list shows tray counts where `tray_count` is set
- [ ] Items with `bake_lead_days = null` and `on_pull_list = false` do not appear on any section (graceful handling)
- [ ] Report correctly separates retail items (same-day delivery) from wholesale items (next-day delivery)
