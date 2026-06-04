# Bakecycle — Agent Context

Bakery operations SaaS app. Rails + React + PostgreSQL.

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
- **Background jobs** Resque 2.x + Redis (local)
- **Asset pipeline** Sprockets + sass-rails + jsbundling-rails (JS bundled via esbuild)
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** React 18 + Redux Toolkit + react-redux 8, bundled with esbuild; Stimulus/Turbo migration in progress

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
| Paperclip → ActiveStorage | not yet (kt-paperclip bridges) |
| React → Stimulus/Turbo (most components) | in progress — see migration plan below |

## Rails 7.1 notes

- Zeitwerk autoloader is active. Report subdirectory classes were moved to `app/reports/` flat.
- `config/boot.rb` requires `"logger"` explicitly — Ruby 3.x no longer auto-requires it.
- All `belongs_to` on nullable FK columns have `optional: true`.
- AMS initializer at `config/initializers/active_model_serializers.rb` — uses 0.10.x API.
- UJS: `rails-ujs` is in `application.js` (not `jquery_ujs`). 16 views use `link_to method: :delete` — these work with rails-ujs as-is. One view uses `remote: true` (`shipments/_double_shipment.html.erb`) for inline AJAX delete. When Turbo is added, `method:` links will need `data: { turbo_method: }` and `remote: true` will need `data: { turbo_stream: true }`.

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

**Components to migrate to Stimulus/Turbo after Rails 7 upgrade** — see section below.

Vendor CSS copied manually (do not overwrite from npm):
- `app/assets/stylesheets/vendor/chosen.css`
- `app/assets/stylesheets/vendor/react-datepicker.css`
- `app/assets/stylesheets/vendor/react-select.css`
- `app/assets/stylesheets/vendor/jquery_ui.scss`

## Specs

Test framework: RSpec. Factories: FactoryBot (`spec/support/factory_girl.rb` is a shim that requires factory_bot_rails).

Run all specs: `bundle exec rspec`
Run one spec: `bundle exec rspec spec/models/bakery_spec.rb`

Current state: **482 examples, 0 failures** (as of Rails 6.1 upgrade).

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

Resque 2.x-based. Worker: `ResqueWorker`. Jobs live in `app/jobs/`.
Redis connection: `REDIS_URL` env var (defaults to `redis://localhost:6379/1`).

## React → Stimulus/Turbo migration plan

Rails 7.1 is running. Next: install `turbo-rails` + `stimulus-rails` and migrate components one at a time. `order-form.jsx` stays in React — its cross-item `totalLeadDays` computation and start-date validation are genuine client-side state that would require a server endpoint to replace cleanly.

**Install:**
```bash
bundle add turbo-rails stimulus-rails
rails turbo:install stimulus:install
```
After Turbo is installed, update the 16 `link_to method: :delete` views to use `data: { turbo_method: :delete }` and the one `remote: true` in `shipments/_double_shipment.html.erb` to use `data: { turbo_stream: true }`.

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
- `aws-sdk-s3` (via kt-paperclip) — file upload/download not covered by specs; verify S3 works in staging before any Paperclip → ActiveStorage migration.
- `resque 2.x` — Solid Queue is Rails 8 default. Resque still works; migrate when convenient.
- `stripe < 6` — pinned; don't bump without a dedicated audit of the Stripe integration.
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

### Token Reference
| Token | Value | Usage |
|---|---|---|
| `$bc-shakespeare` | `#55aad7` | Primary brand blue — links, active states |
| `$bc-limed-spruce` | `#323c46` | Dark header/nav backgrounds |
| `$bc-alizarin-crimson` | `#eb3232` | Destructive / error |
| `$bc-lima` | `#7ed321` | Success |
| `$bc-scorpion` | `#5a5a5a` | Body text |
| `$bc-off-white` | `#f2f3f4` | Page background |

Font: **Open Sans** (300/400/600/700/800), self-hosted via `base/font_setup.scss`.
