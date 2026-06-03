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
- **Rails** 6.1.7
- **DB** PostgreSQL (local)
- **Background jobs** Resque 2.x + Redis (local)
- **Asset pipeline** Sprockets + sass-rails + jsbundling-rails (JS bundled via esbuild)
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** React 18 + Redux Toolkit + react-redux 8, bundled with esbuild

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
| Paperclip → ActiveStorage | not yet (kt-paperclip bridges) |
| Rails 6.1 → 7.1 | not yet — checklist below |
| React → Stimulus/Turbo (most components) | not yet — do after Rails 7 (see below) |

## Rails 6.1 migration notes

- `config/application.rb` sets `config.autoloader = :classic` — Zeitwerk migration deferred to Rails 7 hop.
- `config/boot.rb` requires `"logger"` explicitly — Ruby 3.x no longer auto-requires it.
- All `belongs_to` associations on nullable FK columns have `optional: true` — Rails 5+ makes them required by default.
- `scope :search` in `shipment.rb` uses `Shipment` explicitly instead of `self` — Rails 6 scope lambdas have `self` as the relation, not the class.
- AMS initializer at `config/initializers/active_model_serializers.rb` — uses 0.10.x API (`ActiveModelSerializers.config`).

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
npm run build:prod     # minified production build (665 KB)
npm run build:watch    # watch mode for development
npm test               # Jest (52 tests)
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

## Rails 6.1 → 7.1 upgrade checklist

Target: **Rails 7.1** (stable, well-documented, good stepping stone to 8). Do items roughly in order — the Zeitwerk migration is the biggest risk and should be done first so everything else can be verified against a working autoloader.

### 1. Zeitwerk autoloader (blocker — Rails 7 removes classic mode)

`config.autoloader = :classic` must become `:zeitwerk`. This is the most disruptive change.

**The problem:** Three report subdirectories are added to `autoload_paths` with un-namespaced classes:
- `app/reports/client_reports/client_list_generator.rb` → class `ClientListGenerator` (not `ClientReports::ClientListGenerator`)
- `app/reports/invoice_reports/total_sales_generator.rb` → class `TotalSalesGenerator`
- `app/reports/product_reports/` → 4 classes, all un-namespaced

Zeitwerk expects the directory name to map to a module namespace. **Fix:** move all files from the three subdirectories up into `app/reports/` and remove the `autoload_paths` additions. The class names are unique enough that no conflict risk — `TotalGenerator` and `TotalXlsx` in `client_reports/` are the only potentially generic ones (rename them `ClientTotalGenerator` / `ClientTotalXlsx` if needed). Remove the `autoload_paths +=` block for these subdirs from `application.rb` once files are moved.

Run `bundle exec rails zeitwerk:check` to verify before and after. Fix any "expected ... to define ..." errors before proceeding.

### 2. Replace `devise-async` gem (blocker — unmaintained git fork)

`user.rb` has `devise :async` which sends email via the `devise-async` git fork. Rails 6+ Devise has native `deliver_later` support built in — no gem needed.

**Fix:**
- Remove `gem "devise-async"` from Gemfile
- Remove `:async` from `devise` call in `app/models/user.rb`
- Add to `config/initializers/devise.rb`: `config.send_email_changed_notification = true` (and other email opts as needed)
- Devise will now use `deliver_later` automatically when a queue adapter is configured (Resque is already set up)

### 3. Replace `axlsx` + `axlsx_rails` → `caxlsx` + `caxlsx_rails` (blocker — axlsx is unmaintained)

`axlsx 2.0.1` is pinned because it's abandoned. The community successor `caxlsx` is a drop-in replacement with the same API.

- `gem "axlsx", "2.0.1"` → `gem "caxlsx"`
- `gem "axlsx_rails"` → `gem "caxlsx_rails"`
- `gem "rubyzip", "1.0.0"` → remove pin; `caxlsx` requires rubyzip 2.x

**Rubyzip audit:** grep for `Zip::` in the app — if any code calls `Zip::ZipFile` (v1 API), rename to `Zip::File` (v2 API). Run the xlsx report specs after.

### 4. Remove `uglifier` (blocker — asset pipeline change)

`config/environments/production.rb` sets `config.assets.js_compressor = :uglifier`. esbuild is now handling JS bundling and minification — Sprockets doesn't need to compress JS anymore.

**Fix:**
- Remove `gem "uglifier"` if it's in the Gemfile (it may be implicit)
- Set `config.assets.js_compressor = nil` in `production.rb` (or remove the line)

### 5. UJS: `jquery_ujs` → `rails-ujs` or Turbo

4 views use `link_to method: :delete` (log out, cancel account, delete shipment) which relies on `jquery_ujs` intercepting clicks. Rails 7 with Turbo handles this natively with `data-turbo-method`.

**Options (pick one):**
- Keep `jquery-rails` + `jquery_ujs` — still works in Rails 7, lowest effort
- Switch to `rails-ujs` (vanilla JS, ships with Rails) — remove `jquery-rails` and swap `//= require jquery_ujs` for `//= require rails-ujs`
- Add Turbo and use `data: { turbo_method: :delete }` — the Rails 7 idiomatic way, sets up Turbo for future Hotwire work

### 6. Bump `config.load_defaults` to 7.1

Change `config.load_defaults 6.1` → `config.load_defaults 7.1` in `application.rb`.

New defaults that need attention:
- `action_controller.raise_on_open_redirects = true` — audit all `redirect_to params[:return_to]` or similar user-supplied redirect URLs
- `active_record.verify_foreign_keys_for_fixtures = true` — run specs; fix any fixture FK violations
- Session cookie digest changes (`SHA256`) — existing sessions will be invalidated on deploy (expected, one-time)

### 7. Update Rails gem and run the upgrade task

```bash
# In Gemfile:
gem "rails", "~> 7.1.0"

bundle update rails
bundle exec rails app:update   # review each diff carefully; don't blindly accept
bundle exec rails zeitwerk:check
bundle exec rspec
```

### 8. Gem compatibility audit

Check these gems before bumping Rails — some may need version bumps alongside:

| Gem | Risk | Action |
|---|---|---|
| `draper` | Medium — had Rails 7 issues in older versions | Bump to latest (4.x), run decorator specs |
| `simple_form` | Low | Bump to 5.x if not already |
| `paper_trail` | Low | Ensure 14.x or later |
| `pundit` | Low | Works with Rails 7 |
| `kt-paperclip` | Medium | Verify S3 upload/download in staging after upgrade |
| `cucumber-rails` | Low | Bump to 2.6+ if needed |
| `stripe < 6` | Low (pinned) | Keep pin; don't bump during Rails upgrade |
| `geocoder` | Low | Works with Rails 7 |
| `capistrano3-puma` | Low | Bump if needed for Puma 6 compat |

### 9. After Rails 7 is stable: add Hotwire

```ruby
# Gemfile
gem "turbo-rails"
gem "stimulus-rails"
```

Then begin the React → Stimulus migration from the table above.

---

## Post-Rails 7: React → Stimulus/Turbo migration

Most React components exist because the app predates Hotwire (Rails 7, 2021). After the Rails 7 upgrade brings Stimulus and Turbo in for free, replace these components one at a time. **Do not attempt before Rails 7 — Hotwire is not available in Rails 6.**

The order-form is intentionally excluded: its cross-item `totalLeadDays` computation + start-date validation is the only genuine client-side state machine. Keep it in React or move validation to a server endpoint first.

| Component(s) | Replace with | Notes |
|---|---|---|
| `file-export-refresher.jsx` | Turbo Frame + polling | Turbo 8 has native `<turbo-frame>` refresh intervals. Delete the jQuery `$.get` polling entirely. Start here — smallest and self-contained. |
| `clients-table.jsx` | Stimulus controller | One controller handles name/active/status filters and the Enter-to-navigate shortcut. Read client JSON from a `data-` attribute. Biggest complexity-to-value mismatch in the codebase. |
| `client-map.jsx` + `client-marker.jsx` | Stimulus controller | Init Google Maps in `connect()`, read lat/lng from `data-` attributes on marker elements. |
| `product-price-form.jsx` + `product-price-fields.jsx` | Stimulus nested-form controller | Standard Rails `accepts_nested_attributes_for` dynamic rows. Use [stimulus-components/nested-form](https://github.com/stimulus-components/stimulus-components) or write a small custom controller (~40 lines). |
| `costing-form.jsx` + `costing-item-fields.jsx` | Stimulus controller | Redux is holding 3 values (ingredients array, filter array, weightUnitOptions). Move filter state to a Stimulus value; render ingredient rows server-side. Mirror of the clients-table filter pattern. |
| `vendor-pricing-form.jsx` + `pricing-item-fields.jsx` | Stimulus controller | Identical pattern to costing-form. Do both at the same time. |
| `recipe-form.jsx` + `recipe-items-form.jsx` + `recipe-item-fields.jsx` | Stimulus controller + SortableJS | Add/remove rows → nested-form controller (same as product-price-form). Drag-and-drop → [SortableJS](https://github.com/SortableJS/Sortable) via a Stimulus controller; write the new `sort_id` values back to hidden inputs on `end` event. Do last — most moving parts. |

**After all components are migrated:** remove `react`, `react-dom`, `react-redux`, `@reduxjs/toolkit`, `redux`, `create-react-class` from `package.json`. The esbuild pipeline and Jest tests can stay.

## Known pain points for future upgrade hops

- `active_model_serializers 0.10` — serializers updated but API response shape should be verified in-browser; no spec coverage for JSON output.
- `rubyzip 1.0.0` — pinned; v2 has breaking API changes. Audit usages before bumping.
- `aws-sdk-s3` (via kt-paperclip) — file upload/download not covered by specs; verify S3 works in staging before shipping.
- `resque 2.x` — Solid Queue is Rails 8 default. Resque still works; migrate when convenient.
- `axlsx 2.0.1` — community successor is `caxlsx`. Check compatibility before Rails 7.
- `devise-async` git fork — non-standard. Can be replaced with native ActiveJob delivery in Rails 6+.
- `jquery-rails` — jQuery not needed for Rails 7 UJS (which uses vanilla JS). Remove at Rails 7 hop.
- `config.autoloader = :classic` — must migrate to Zeitwerk before Rails 7. Requires file/class naming audit.
- React 18 + RTK — remaining React components are candidates for Stimulus/Turbo replacement after Rails 7; see migration table above. `order-form.jsx` stays React until server-side validation endpoint exists.
