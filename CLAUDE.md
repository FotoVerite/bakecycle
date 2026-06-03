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
- **Asset pipeline** Sprockets + sass-rails + browserify-rails (JS bundled via Browserify; see below)
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** React 0.14 + Redux 3 + Backbone, bundled with Browserify + Babel 6

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
| Browserify → esbuild/importmap | not yet |
| React 0.14 → 18 | not yet |
| Paperclip → ActiveStorage | not yet (kt-paperclip bridges) |
| Rails 6.1 → 7.x | not yet |

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

## JavaScript (Browserify era — pre-upgrade)

JS is bundled via `browserify-rails 4.3.0`. Entry point: `app/assets/javascripts/app.js`.
Babel 6 transpiles JSX + ES2015.

**Do not touch JS bundling** until the Rails upgrade is stable. The Browserify → esbuild migration is a separate workstream.

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

## Known pain points for future upgrade hops

- `active_model_serializers 0.10` — serializers updated but API response shape should be verified in-browser; no spec coverage for JSON output.
- `browserify-rails` — incompatible with Rails 7+. Replace with `jsbundling-rails` + esbuild at Rails 7 hop.
- `rubyzip 1.0.0` — pinned; v2 has breaking API changes. Audit usages before bumping.
- `aws-sdk-s3` (via kt-paperclip) — file upload/download not covered by specs; verify S3 works in staging before shipping.
- `resque 2.x` — Solid Queue is Rails 8 default. Resque still works; migrate when convenient.
- `axlsx 2.0.1` — community successor is `caxlsx`. Check compatibility before Rails 7.
- `devise-async` git fork — non-standard. Can be replaced with native ActiveJob delivery in Rails 6+.
- `jquery-rails` — jQuery not needed for Rails 7 UJS (which uses vanilla JS). Remove at Rails 7 hop.
- `config.autoloader = :classic` — must migrate to Zeitwerk before Rails 7. Requires file/class naming audit.
- React 0.14 + Redux 3 — extremely old; upgrading requires full frontend rewrite alongside JS bundler migration.
