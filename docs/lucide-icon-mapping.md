# Lucide Icon Migration List

Foundation Icons are currently used through `fi-*` classes plus a few custom SVG nav icons. The migration should move icon names to Lucide keys and render them through a shared Rails helper so ERB, pinned-action config, dashboards, and table actions all use one vocabulary.

Recommended package: `lucide-static`. It gives us raw SVG files that can be rendered server-side without React or Turbo timing concerns.

## Shared Action Icons

| Current icon | Lucide icon | Use |
| --- | --- | --- |
| `fi-page-edit` | `pencil` | Edit actions across tables |
| `fi-eye` | `eye` | View record / Papertrail |
| `fi-page-copy` | `copy` | Copy order |
| `fi-page-add` | `file-plus` | New order, new invoice, create future invoices |
| `fi-page-delete` | `file-x` | Delete invoice warning rows |
| `fi-trash` | `trash-2` | Remove nested rows |
| `fi-x` | `x` | Remove, close, no |
| `fi-refresh` | `rotate-ccw` | Reset filters, restore nested rows |
| `fi-magnifying-glass` | `search` | Search and empty search state |
| `fi-print` | `printer` | Print |
| `fi-page-export` | `download` | Generic export |
| `fi-page-export-pdf` | `file-text` | PDF/exported document |
| `fi-page-export-csv` | `file-spreadsheet` | CSV export |
| `fi-dollar` | `dollar-sign` | QuickBooks / financial export |
| `fi-dollar-bill` | `banknote` | Sales report |
| `fi-mail` | `mail` | Resend confirmation email |
| `fi-database` | `database` | Vendor buy orders |
| `fi-alert` | `triangle-alert` | Errors, job warnings, operational warnings |
| `fi-check` | `check` | Complete, pinned, online |
| `fi-checkbox` | `square-check` | Checklist / yes state |
| `fi-bookmark` | `bookmark` | Pinned actions |
| `fi-widget` | `settings` | Manage pins / account utility |
| `fi-list` | `list` | Menus, drag handles, pin list |
| `fi-arrow-left` | `arrow-left` | Back |
| `fi-arrow-right` | `arrow-right` | Forward/open |
| `fi-arrow-up` | `arrow-up` | Move pin up |
| `fi-arrow-down` | `chevron-down` | Expand nav/account menus |

## Navigation

| Current asset/icon | Lucide icon | Use |
| --- | --- | --- |
| `icons/icon-dashboard.svg` | `layout-dashboard` | Dashboard |
| `fi-graph-bar` | `chart-bar` | Reports |
| `icons/icon-client.svg` | `users` | Clients group |
| `icons/icon-production.svg` | `wheat` | Production group |
| `icons/icon-shipping.svg` | `truck` | Shipping group |
| `icons/icon-product.svg` | `package` | Catalog group |
| `fi-arrow-down.nav-caret` | `chevron-down` | Collapsible group caret |

## Pinned Actions Registry

Update `config/pinned_actions.yml` to store Lucide keys instead of Foundation classes.

| Action key | Current icon | Lucide icon |
| --- | --- | --- |
| `new_order` | `fi-page-add` | `file-plus` |
| `new_invoice` | `fi-page-add` | `file-plus` |
| `daily_recipes` | `fi-clipboard-notes` | `clipboard-list` |
| `batch_recipes` | `fi-calendar` | `calendar-days` |
| `production_runs` | `fi-results` | `list-checks` |
| `production_checklist` | `fi-checkbox` | `square-check` |
| `packing_slips` | `fi-page-export-pdf` | `file-text` |
| `delivery_lists` | `fi-list-thumbnails` | `list-todo` |
| `nightly_sign_off` | `fi-check` | `check-check` |
| `reports` | `fi-graph-bar` | `chart-bar` |
| `clients` | `fi-torsos-all` | `users` |
| `orders` | `fi-shopping-bag` | `shopping-bag` |
| `invoices` | `fi-page-multiple` | `files` |
| `products` | `fi-price-tag` | `tag` |
| `recipes` | `fi-clipboard-notes` | `clipboard-list` |

## Dashboard Cards

| Surface | Current icon | Lucide icon |
| --- | --- | --- |
| Clients count | `fi-torsos-all` | `users` |
| Orders count | `fi-shopping-bag` | `shopping-bag` |
| Invoices count | `fi-calendar` | `files` |
| Routes count | `fi-foundation` | `map` |
| Production runs count | `fi-calendar` | `calendar-days` |
| Ingredients count | `fi-info` | `wheat` |
| Recipes count | `fi-info` | `clipboard-list` |
| Products count | `fi-price-tag` | `tag` |
| Users count | `fi-torso` | `user` |
| Bakeries count | `fi-torsos-all` | `building-2` |
| Orders created/updated | `fi-shopping-bag` | `shopping-bag` |
| Recipes created/updated | `fi-info` | `clipboard-list` |
| Products created/updated | `fi-info` | `package` |
| Files accessed | `fi-shopping-bag` | `file-clock` |
| Daily Recipes operation | `fi-clipboard-notes` | `clipboard-list` |
| Production Checklist operation | `fi-checkbox` | `square-check` |
| Packing Slips operation | `fi-page-export-pdf` | `file-text` |
| Nightly Sign Off operation | `fi-check` | `check-check` |
| Job queue online/offline | `fi-check` / `fi-alert` | `check` / `triangle-alert` |

## Reports Page

| Report | Current icon | Lucide icon |
| --- | --- | --- |
| Production Daily/Weekly Totals | `fi-graph-bar` | `chart-bar` |
| Production Date Range Total | `fi-calendar` | `calendar-range` |
| Grocery List | `fi-shopping-cart` | `shopping-cart` |
| Client Daily/Weekly Totals | `fi-results-demographics` | `users` |
| VIP List | `fi-crown` | `crown` |
| Client Totals | `fi-graph-pie` | `chart-pie` |
| Product Daily/Weekly Totals | `fi-graph-horizontal` | `chart-bar` |
| Ingredient Pricing | `fi-pricetag-multiple` | `tags` |
| Product Pricing | `fi-price-tag` | `tag` |
| Clients Per Product | `fi-torsos-all` | `users` |
| Nightly Sign Off | `fi-clipboard-notes` | `clipboard-list` |
| Detailed Invoice Report | `fi-page-search` | `file-search` |
| Total Sales Report | `fi-dollar-bill` | `banknote` |

## Report And Export Buttons

These appear in clients, products, production runs, shipments, daily totals, delivery lists, projections, and invoice/report pages.

| Current icon | Lucide icon | Use |
| --- | --- | --- |
| `fi-page-export-pdf` | `file-text` | Print PDF/report document |
| `fi-page-export` | `download` | Export Excel/generic file |
| `fi-page-export-csv` | `file-spreadsheet` | Export CSV |
| `fi-dollar` | `dollar-sign` | Export QuickBooks IIF |
| `fi-print` | `printer` | Print commands |

## Form And Nested Row Icons

| Current icon | Lucide icon | Use |
| --- | --- | --- |
| `fi-x` | `x` | Remove row / No |
| `fi-trash` | `trash-2` | Delete nested row |
| `fi-refresh` | `rotate-ccw` | Restore nested row |
| `fi-list` | `grip-vertical` | Sort handle |
| `fi-checkbox` | `square-check` | Yes |
| `fi-alert` | `triangle-alert` | Form errors and warnings |

## Notes

- Prefer business meaning over one-for-one replacement. `fi-info` should usually become `wheat`, `clipboard-list`, or `package`, depending on the card.
- Prefer `file-text` for documents people read/print, `download` for exports, and `file-spreadsheet` for CSV/Excel.
- Keep Lucide stroke width consistent globally. The default 2px is fine; avoid mixing filled icons with outline icons.
- After the helper exists, remove the `foundation-icons` import only after every `fi-*` reference is gone.
