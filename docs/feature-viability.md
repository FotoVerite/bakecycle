# Bakecycle Feature Viability Overview

Full specs in `docs/specs/`. This document is the summary and timeline.

---

## Summary

| # | Feature | Effort | Viability | Spec |
|---|---------|--------|-----------|------|
| 1 | Sample Orders | Medium (1–1.5 wks) | High | [01-sample-orders.md](specs/01-sample-orders.md) |
| 2 | Item Projections + Tray Counts | Medium (1–1.5 wks) | High | [02-item-projections.md](specs/02-item-projections.md) |
| 3 | Cancellations | Low-Medium (0.5–1 wk) | High | [03-cancellations.md](specs/03-cancellations.md) |
| 4 | Bake List | High (2–3 wks) | Medium-High | [04-bake-list.md](specs/04-bake-list.md) |
| 5 | Nightly Sign Off | Low-Medium (0.5–1 wk) | High | [05-nightly-sign-off.md](specs/05-nightly-sign-off.md) |

**Total estimated range: 5.5–8.5 weeks.** At the low end this fits in a month; at the high end it needs prioritization or phasing.

---

## Rough 4-Week Timeline

### Week 1
- **#3 Cancellations** — smallest scope, immediate daily value, no new data model
- **#1 Sample Orders** — contained model change, unblocks current workaround of fake accounts

### Week 2
- **#5 Nightly Sign Off** — once questions about segmentation (Blue Bottle / Joe / Bien Cuit) are answered
- **#2 Item Projections** (start) — migration for `tray_count`, new projection report

### Week 3
- **#2 Item Projections** (finish)
- **#4 Bake List** (start) — migrations for `bake_lead_days`, `on_pull_list`, product form updates

### Week 4
- **#4 Bake List** (finish) — report generation, per-location pars
- Buffer / polish / QA

---

## Pre-work Required (Before Any Code)

The features below are blocked until the client answers questions in the individual specs. Gather these answers in the next client meeting:

**#1 Sample Orders**
- ✅ Sample items appear on the production run (confirmed)
- How should they be labeled on the production run — "SAMPLE" inline, or a separate section?
- Should the sample delivery appear on the route delivery list alongside regular orders?
- Should sample invoices be emailed to clients?

**#2 Item Projections**
- Is the report one aggregate total per product, or broken out by delivery date?
- Is tray count fixed per product or per variant?

**#3 Cancellations**
- If a client already has a non-zeroed temporary order, zero it out or warn + skip?
- Is "select all on route" needed for bulk closures?

**#4 Bake List** (most questions — answers needed before Phase 1 migrations)
- Is bake lead time fixed per product, or can a product be both retail and wholesale?
- Are Smith and Franklin the only locations needing pars?
- What's the scope of the Viennoiserie Pick — only `vienoisserie` product type or broader?

**#5 Nightly Sign Off**
- How are Blue Bottle clients identified in the current data (route name? client flag?)?
- How are Bien Cuit accounts identified?
- Where do box/bag counts come from?

---

## Notes on Upgrade Branch

The codebase is mid-upgrade (Rails 7.1 running on the `upgrade` branch). New features go on top of the upgrade. Staging can break without affecting production. Recommend:
- All new migrations use `add_column` with safe defaults (nullable or `default: value`)
- New reports follow the existing `FileExport` + background job pattern to avoid timeouts
- No structural changes to existing report files — add new ones
