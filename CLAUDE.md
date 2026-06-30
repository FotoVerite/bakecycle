# Bakecycle — Agent Context

Bakery operations SaaS app. Rails + Stimulus/Turbo + PostgreSQL. (React was fully removed — see migration plan below.)

## How to run

Runs natively on Ruby 3.1.1 (arm64-darwin). No Docker required for development.

```bash
bundle exec rails server          # start app
bundle exec rspec                 # run all specs
bundle exec rspec spec/models/bakery_spec.rb  # run one spec
bundle exec rails db:migrate
```

PostgreSQL and Redis must be running locally (e.g. via Homebrew services).

## Stack

- **Ruby** 3.1.1 (arm64-darwin, native — not Docker)
- **Rails** 7.1.6
- **DB** PostgreSQL (local)
- **Background jobs** Solid Queue (DB-backed, no Redis dependency). Redis is still used, but only for Action Cable (`config/cable.yml`).
- **Asset pipeline** Sprockets + jsbundling-rails (JS via esbuild) + cssbundling-rails (CSS via Dart Sass). **Important:** the dev server serves the *built* files (`app/assets/builds/application.css`, `app/assets/builds/bakecycle.js`), not live-compiled source — see "Asset build gotcha" below.
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** Stimulus + Turbo (`@hotwired/turbo`, `turbo-rails` gem). React/Redux fully removed (see migration plan below).

## Upgrade status (branch: `upgrade`)

| Step | Status |
|------|--------|
| Rails 5.1 → 5.2 | ✅ done |
| Foundation gem → vendored SCSS | ✅ done |
| paperclip → kt-paperclip | ✅ done |
| Ruby 2.5.1 → 3.1.1 | ✅ done |
| Rails 5.2 → 6.1 | ✅ done |
| active_model_serializers 0.9 → 0.10 | ✅ done (initializer rewritten) |
| aws-sdk v1 removed | ✅ done (kt-paperclip handles S3 directly) |
| Browserify → esbuild | ✅ done (jsbundling-rails + esbuild, 52 Jest tests) |
| React 0.14 → 18 | ✅ done (RTK, no deprecated lifecycle methods) |
| Rails 6.1 → 7.1 | ✅ done (running 7.1.6) |
| Cucumber removed → RSpec request specs | ✅ done |
| Paperclip → ActiveStorage | **not planned** — kt-paperclip is actively maintained; do not migrate |
| React → Stimulus/Turbo | ✅ done — see migration plan below |
| Resque → Solid Queue | ✅ done |

## Rails 7.1 notes

- Zeitwerk autoloader is active. Report subdirectory classes were moved to `app/reports/` flat.
- `config/boot.rb` requires `"logger"` explicitly — Ruby 3.x no longer auto-requires it.
- All `belongs_to` on nullable FK columns have `optional: true`.
- AMS initializer at `config/initializers/active_model_serializers.rb` — uses 0.10.x API.
- Turbo Drive is active app-wide (`@hotwired/turbo` + `turbo-rails`). All former `link_to method: :delete` views were migrated to `data: { turbo_method: :delete }`; the one `remote: true` view (`shipments/_double_shipment.html.erb`) was migrated to `data: { turbo_method:, turbo_confirm: }`.
- **Devise + Turbo gotcha:** `config/initializers/devise.rb` sets `config.responder.error_status = :unprocessable_entity` and `config.responder.redirect_status = :see_other`. Without these, Devise's failure app (e.g. bad sign-in credentials) returns the form re-render with HTTP `200` — Turbo Drive then throws `"Form responses must redirect to another location"` in the browser console for every failed login. This is a known Devise 5 default (`error_status: :ok` for backwards compatibility); the installer's own Turbo-app template sets these two lines. **Do not remove them.**
- **YAML safe-load gotcha:** Rails 7's `ActiveRecord.yaml_column_permitted_classes` defaults to `[Symbol]` only. Any YAML-serialized column holding `BigDecimal`/`Date`/`Time` (e.g. PaperTrail's `versions.object_changes`) will silently fail to deserialize — the exception is rescued and the column reads as `{}`/`nil` with no error raised. `config/initializers/paper_trail.rb` extends the permitted list. If you add another YAML-serialized column elsewhere, check this list first before assuming "no changes" means "nothing changed."

## CSS: Foundation 5.5 (vendored)

Foundation 5.5 SCSS is vendored directly — the gem was removed because it had no Rails 6+ release.

**File layout:**
```
vendor/assets/stylesheets/
  foundation.scss                      # root import (all components)
  _foundation-icons.scss               # wrapper → imports subdir
  normalize.scss
  foundation/
    _functions.scss
    _settings.scss
    components/
      _grid.scss  _buttons.scss  ...   # 38 components
  foundation-icons/
    _foundation-icons.scss             # font-face (uses font-url() for Rails pipeline)
vendor/assets/fonts/
  foundation-icons.{eot,svg,ttf,woff}
```

**Import chain:**
`application.scss` → `base/foundation_and_overrides.scss` → `@import 'foundation'` + `@import 'foundation-icons'`

`foundation_and_overrides.scss` is the settings file (1400 lines of commented-out Foundation variables). The only active settings are:
- `$include-html-classes: true`
- `$font-family-sans-serif: "Open Sans", sans-serif`

**Foundation classes used in views** (do not rename without a full grep):
- Grid: `row`, `columns`, `small-12`, `medium-4`, `medium-6`, `large-4`, `large-6` (310+ instances)
- Components: `panel`, `alert-box`, `callout`, `radius`, `label`, `collapse`
- Icons: `fi-page-export`, `fi-page-edit`, `fi-info` (foundation-icons)
- `@extend .panel` is used in `base/main.scss`

## File attachments: kt-paperclip

Switched from `paperclip ~> 4.2` to `kt-paperclip ~> 6.4` (drop-in API replacement).
S3 storage config is in `config/initializers/paperclip.rb` — unchanged.
aws-sdk v1 was removed; kt-paperclip brings its own aws-sdk-s3 dependency.

Models using attachments:
- `app/models/bakery.rb` — `has_attached_file :logo`
- `app/models/file_export.rb` — `has_attached_file :file`

## JavaScript

esbuild bundles `app/assets/javascripts/app.js` → `app/assets/builds/bakecycle.js`.
Jest tests live in `spec/javascript/`. Run with `npm test`.

```bash
npm run build          # dev build
npm run build:prod     # minified production build (~317 KB)
npm run build:watch    # watch mode for development
npm test               # Jest (0 tests remain — all React tests deleted)
npm run test:watch     # Jest watch mode
```

## Asset build gotcha (CSS and JS — read before debugging "my style change isn't showing up")

`bundle exec rails server` does **not** live-compile Sass or JS. It serves whatever is currently sitting in `app/assets/builds/application.css` and `app/assets/builds/bakecycle.js`. Editing a `.scss` or `.js` source file has zero effect on the running app until one of these runs:

```bash
bundle exec rails dartsass:build   # rebuilds application.css from Sass sources
npm run build                      # rebuilds bakecycle.js from app.js
```

or the watch processes (`bin/rails dartsass:watch`, `npm run build:watch` — both registered in `.claude/launch.json`) are running continuously.

**Only `application.css` is committed** — `app/assets/builds/*.js` is gitignored (`.gitignore:29`), so `bakecycle.js` must be rebuilt locally/in CI but never needs (and never should) show up in `git status`. `application.css` is a tracked, committed file, so a CSS source change isn't actually shipped until the rebuilt file is committed alongside it.

`bundle exec rails assets:precompile` (which compiles into `public/assets/` for production) is a **separate** pipeline and is not a substitute for the above — running it does *not* update `app/assets/builds/*`, so "it precompiled with no errors" only proves the Sass/JS syntax is valid, not that your change is live. If you use `assets:precompile` to sanity-check Sass syntax during a session, remember the actual `app/assets/builds/*.css`/`.js` files still need rebuilding for the change to ship at all.

Vendor CSS copied manually (do not overwrite from npm):
- `app/assets/stylesheets/vendor/chosen.css`
- `app/assets/stylesheets/vendor/react-datepicker.css`
- `app/assets/stylesheets/vendor/react-select.css`
- `app/assets/stylesheets/vendor/jquery_ui.scss`

## Specs

Test framework: RSpec. Factories: FactoryBot (`spec/support/factory_girl.rb` is a shim that requires factory_bot_rails).

Run all specs: `bundle exec rspec`
Run one spec: `bundle exec rspec spec/models/bakery_spec.rb`

Current state: **748 examples, 0 failures** (as of the PaperTrail/Turbo/icon-system fixes below).

Common spec support files:
- `spec/support/factory_girl.rb` — FactoryBot config
- `spec/support/pundit.rb` — policy helpers
- `spec/support/webmock.rb` — HTTP stubbing

## Key models

| Model | Notes |
|-------|-------|
| Bakery | multi-tenant root; has logo attachment |
| Client | belongs to Bakery |
| Order | recurring orders per client |
| Product | belongs to Bakery, has recipes |
| Recipe / BatchRecipe | production recipes |
| ProductionRun | scheduled production |
| Shipment / ShipmentItem | delivery tracking; uses Denormalization concern |
| FileExport | background-generated file with S3 attachment |

## Background jobs

Solid Queue (DB-backed via the `solid_queue` gem — no Redis dependency for jobs). Jobs live in `app/jobs/`.
Worker config: `config/queue.yml`. Recurring/scheduled jobs: `config/recurring.yml` (per-environment, e.g. `production:`/`staging:` keys).

Recurring jobs currently configured:
- `clear_solid_queue_finished_jobs` — hourly, prunes Solid Queue's own job-history table.
- `purge_old_versions` — daily at 3am, runs `PurgeOldVersionsJob` (90-day retention on PaperTrail's `versions` table — see PaperTrail section below).

Redis is still used, but only for Action Cable (`config/cable.yml`), not for job queuing.

## PaperTrail (audit trail)

Tracked models: `OrderItem`, `Product`, `PriceVariant`, `Recipe`, `RecipeItem`. Per-record history is viewable at `/products/:id/papertrail`, `/recipes/:id/papertrail`, `/orders/:id/papertrail` (controller actions + views named `papertrail`), rendered via the shared `shared/_papertrail_timeline` partial. Styling lives in `app/assets/stylesheets/app/_papertrail.scss`.

**Retention:** `PurgeOldVersionsJob` runs daily, deleting `versions` rows older than 90 days in batches. One-off backlog cleanup task: `rake versions:purge_order_item_backlog` (batched `OrderItem`-only delete; was used once to clear a historical 64M-row/22GB backlog — see below). `versions.created_at` has an index to keep both queries off a full table scan.

**Why `OrderItem` has `on: %i[create update destroy]` instead of the gem default:** PaperTrail's default `on:` list includes `:touch`. `Product#queue_touch_order_items` (an `after_commit`) touches every order item belonging to a product whenever that product is saved, gated by `lead_days_relevant_change?` (only fires when `motherdough_id`/`inclusion_id`/`lead_days_override`/`total_lead_days` actually changed — *not* on every unrelated product edit). Before this fix, that callback combined with default touch-tracking generated a version row for every order item on every product save regardless of relevance, producing ~64.6M rows (99.8% of the table) of pure noise with empty `object_changes`. If you add `has_paper_trail` to a new model that gets `.touch`ed by another model's callback, consider whether `on:` should exclude `:touch` for the same reason.

**Don't assume "no changes shown" means PaperTrail is broken or that nothing changed** — check `ActiveRecord.yaml_column_permitted_classes` first (see the YAML safe-load gotcha under "Rails 7.1 notes"). This silently broke every papertrail view's change history for an unknown period after the Rails 7 upgrade.

## React → Stimulus/Turbo migration plan

**Fully complete** — `turbo-rails` + `stimulus-rails` are installed and active app-wide (see the Devise + Turbo gotcha under "Rails 7.1 notes" for a real incompatibility this surfaced). All `link_to method: :delete` and `remote: true` views were migrated to `data: { turbo_method: }` equivalents.

### Migration order

| Priority | Component(s) | Replace with | Status |
|---|---|---|---|
| 1 | `file-export-refresher.jsx` | Stimulus polling controller | ✅ done |
| 2 | `client-map.jsx` + `client-marker.jsx` | Stimulus controller | ✅ done |
| 3 | `product-price-form.jsx` + `product-price-fields.jsx` | Stimulus nested-form controller | ✅ done |
| 4 | `clients-table.jsx` | Stimulus filter + server-side table | ✅ done |
| 5 | `costing-form.jsx` + `costing-item-fields.jsx` | Stimulus filter controller | ✅ done |
| 6 | `vendor-pricing-form.jsx` + `pricing-item-fields.jsx` | Stimulus filter controller | ✅ done |
| 7 | `recipe-form.jsx` + `recipe-items-form.jsx` + `recipe-item-fields.jsx` | Stimulus nested-form + SortableJS | ✅ done |
| 8 | `order-form.jsx` + Redux store | Stimulus `order-form` + `order-item` controllers | ✅ done |

**Migration complete.** React, Redux, moment.js, react-datepicker, react-select, prop-types, lodash.* (order), and all related serializers/models have been removed. esbuild pipeline and Jest infrastructure remain but no tests exist yet.

## Known pain points for future upgrade hops

- `active_model_serializers 0.10` — API response shape should be verified in-browser; no spec coverage for JSON output.
- `aws-sdk-s3` (via kt-paperclip) — file upload/download not covered by specs; verify S3 works in staging before any major changes. **Do not migrate to ActiveStorage** — kt-paperclip is actively maintained and this project is staying on it.
- `stripe < 6` — pinned; don't bump without a dedicated audit of the Stripe integration.
- **Production/staging `versions` table** — the 64M-row PaperTrail backlog (see PaperTrail section) was cleared locally; if staging/production weren't cleaned up in the same pass, they likely still have it. Check table size before assuming the fix has propagated everywhere.
- `jquery-rails` — jQuery is still needed for jquery-timepicker and jquery-ui-sass-rails. Can be removed when those UI widgets are replaced with native or Stimulus equivalents.
- `order-form.jsx` — migrated to Stimulus. Lead time validation runs client-side in `order_form_controller.js`. No server endpoint needed.

---

## Design Context

Full details in `.impeccable.md`. Summary for quick reference:

### Users
Two audiences in equal measure: **bakery owners/managers** (desk, data-dense, full-session navigation) and **production staff** (kitchen/tablet, quick scanning, floury hands). Design must hold for both.

### Brand Personality
**Reliable workhorse** — dependable, clear, grounded. Professional and direct with enough warmth to feel human. Not cold enterprise software, not a lifestyle brand.

### Aesthetic Direction
Warmer and more approachable than current palette — shift cool greys toward warmer stone tones, keep Shakespeare blue (`#55aad7`) as primary interactive color, Open Sans stays. Avoid startup SaaS pastels or clinical white.

### Design Principles
1. **Clarity first** — One obvious primary action per screen; use visual weight, not decoration, to show hierarchy.
2. **Consistent component vocabulary** — One button style, one form style, one table style, used everywhere. Inconsistency is the primary gap to close.
3. **Warmth through spacing, not color** — Use generous padding and grouping to make dense pages breathable.
4. **Floor-legible type** — Key data values and headings larger than they feel necessary on desktop; production staff may be 2 feet away.
5. **Incremental, not systemic** — Improve components in place; don't require a full design system before shipping.

### Table action icons (`table-action-icon` / `icon-link-tooltip`)

Every table row's "Actions" column uses this pattern (styles in `app/assets/stylesheets/app/_responsive_table.scss`):

```erb
<%= link_to some_path do %>
  <span class="table-action-icon table-action-icon--<variant> icon-link-tooltip" aria-label="Human-readable action">
    <i class="fi-some-icon"></i>
  </span>
<% end %>
```

`aria-label` is required — it drives the hover tooltip via `content: attr(aria-label)` in CSS, not just accessibility. The `--variant` modifier is **required**; omitting it (a bug found and fixed app-wide in 2026-06) silently renders an uncolored circle instead of the intended semantic tint.

| Variant | Hue | Use for |
|---|---|---|
| `--edit` | blue | Editing an existing record in place |
| `--create` | teal | Spawning a *new* record (add, copy/duplicate) — deliberately a different hue from `--edit`, not just a different shade |
| `--document` | grey/neutral | View-only / read-only / export actions (view, papertrail history, PDF/CSV export, resend email) |
| `--fulfillment` | green | Production/operational actions (packing slip) |
| `--financial` | amber | Money/procurement actions (QuickBooks export, buy orders) |
| `--destructive` | red | Delete/remove actions — reuses `$bc-alizarin-crimson`, the same token used for form errors elsewhere |

When adding a new table action, map it to the closest existing semantic bucket above before reaching for a new variant. Only add a new one if the action is genuinely a new category (this is how `--create` and `--destructive` were added — `--edit` was being reused for actions that weren't actually edits, and deletes had no distinct visual treatment at all).

### Token Reference
| Token | Value | Usage |
|---|---|---|
| `$bc-shakespeare` | `#55aad7` | Primary brand blue — links, active states |
| `$bc-limed-spruce` | `#323c46` | Dark header/nav backgrounds |
| `$bc-alizarin-crimson` | `#eb3232` | Destructive / error |
| `$bc-lima` | `#7ed321` | Success |
| `$bc-scorpion` | `#5a5a5a` | Body text |
| `$bc-off-white` | `#f2f3f4` | Page background |
| `$bc-charcoal` | `#555` | Headings, table text |
| `$bc-silver-chalice` | `#a0a0a0` | **Avoid for text** — only ~2.3:1 contrast on white/off-white, fails WCAG AA (4.5:1). Found and fixed in two places in 2026-06 (timestamps, struck-through values in papertrail timeline) by switching to `$bc-scorpion`. The avatar-initial pattern (`.account-avatar`, `.papertrail-avatar`) had the same problem with white text on a too-light `$bc-shakespeare` background (~2.3:1) — fixed by darkening the background to `color.adjust($bc-shakespeare, $lightness: -20%)` (~5:1). If you add a new white-on-color badge/avatar, check contrast before assuming the brand color at default lightness is safe for white text. |

Font: **Open Sans** (300/400/600/700/800), self-hosted via `base/font_setup.scss`.
