# Spec: Item Projections + Tray Counts

**Priority:** #2 | **Effort:** Medium (~1–1.5 weeks) | **Viability:** High

---

## Problem

Projecting next week's item totals requires daily manual tracking because Bakecycle reports pull from *generated invoices*, and invoices only generate as far out as an item's longest lead time. Products with short lead times (Pain de Mie = 2 days) don't generate invoices until 2 days before delivery, so weekly planning requires cross-referencing multiple sources and manual spreadsheet work.

Additionally, reports show individual unit counts only — no tray counts, which are needed for the Viennoiserie Pick and Bake List.

---

## Context: What Already Exists

**`ProductionRunProjection`** (`app/services/production_run_projection.rb`) already queries `OrderItem` records directly for any future date using the `production_date` scope — no pre-generated shipment needed. This is what powers the Production Run Projection report. The new report can use this same engine.

**`DailyProductTotalsXlsx`** (`app/reports/daily_product_totals_xlsx.rb`) is the closest existing report, but it queries `Shipment.where(date:)` — so it only works for dates that have been invoiced. The new projection report will query orders directly instead.

---

## Proposed Solution

### Part A — Order-based product projection report

A new report that queries standing + temporary orders for a delivery date range (not shipments), shows product totals by delivery date, and includes tray counts. Temporary orders override standing orders for the same client/date (existing behavior).

The report does **not** generate any new shipment records — it reads directly from `OrderItem` using the existing `production_date` scope (same engine as `ProductionRunProjection`).

**Report columns:** Product name | Total qty | Trays | Remaining pieces

**Grouping:** By product type (bread, viennoiserie, cookie, etc.), then product name.

**Date range:** User-selectable — default to tomorrow through 10 days out.

### Part B — Tray count field on products

Add a nullable `tray_count` integer to `products`. Products without a tray count (e.g., breads sold individually) leave it null and the column shows "—" in the report.

**Display math:**
- Trays: `(total_qty / tray_count).floor`
- Pieces remainder: `total_qty % tray_count`
- Format: "8 trays, 42 pcs" or "— " if no tray count set

---

## Implementation

### Migration
```ruby
add_column :products, :tray_count, :integer
```

### Product form
Add "Tray Count (pieces per tray)" field to the product edit form. Optional/nullable. Display hint: "Leave blank if this product is not counted by tray."

### New report
- **`OrderProjectionXlsx`** (or similar) — new file in `app/reports/`
- Accepts `bakery`, `start_date`, `end_date`
- Queries `OrderItem` via `ProductionRunProjection` for each date in range
- Aggregates quantities by product across all dates in range
- Adds tray count math per product
- Generates XLSX (follows the same pattern as `DailyProductTotalsXlsx`)

### Controller / FileExport
Add a new entry to the reports page (or extend the existing product totals report) with a date range picker. Wire through the existing `FileExport` + background job pattern so large date ranges don't time out.

---

## Open Questions for Client

1. **Report format — by date or aggregate?** The doc says "product totals for a delivery date" — does the final report show one column per day with totals, or one aggregate total for the whole range? Or both as separate tabs?
2. **Temporary order override**: Confirm the rule — if a client has a standing order AND a temporary order for the same date, does the temporary order completely replace the standing order, or are they summed?
3. **Tray count per product or per recipe/style?** Is the tray count fixed per product (e.g., Croissants always 60/tray) or does it vary by variant?
4. **Report destination**: Is this a new standalone report, or should it replace/extend the existing "Products Daily/Weekly Totals" report?
5. **Cancelled orders**: If a client has a zeroed-out temporary order (cancellation), should the product projection show 0 for that client's items, or exclude them entirely?
6. **10 days vs configurable**: Should 10 days be a fixed window or should the user be able to pick any date range?

---

## Acceptance Criteria

- [ ] `products` table has a nullable `tray_count` integer column
- [ ] Product form allows entering/editing tray count
- [ ] New projection report generates for a user-selected date range without requiring pre-generated invoices
- [ ] Report groups by product type, then product name
- [ ] Tray count column shows "X trays, Y pcs" for products with a tray count set, blank for those without
- [ ] Temporary orders override standing orders for the same client/date
- [ ] Cancelled orders (zeroed temp orders) correctly show 0 or are excluded
