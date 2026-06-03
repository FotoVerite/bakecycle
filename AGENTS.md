# Bakecycle — Agent Context

Bakery operations SaaS app. Rails + React + PostgreSQL.

## How to run

Everything runs via Docker (Ruby 2.5.1 is not in local rbenv):

```bash
docker-compose up --build       # start app + db + redis
docker-compose run web bash     # shell into container
docker-compose run web bundle exec rspec   # run specs
docker-compose run web bundle exec rails db:migrate
```

The web service mounts the repo at `/app`, so file edits take effect without rebuilding unless Gemfile changes.

After any Gemfile change: `docker-compose build` to reinstall gems.

## Stack

- **Ruby** 2.5.1 (compiled in Docker from source; not in local rbenv)
- **Rails** ~> 5.2.0 (upgraded from 5.1.7)
- **DB** PostgreSQL 12 (docker service `db`)
- **Background jobs** Resque + Redis 6 (docker service `redis`)
- **Asset pipeline** Sprockets + sass-rails + browserify-rails (JS bundled via Browserify; see below)
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** React 0.14 + Redux 3 + Backbone, bundled with Browserify + Babel 6

## Upgrade status (branch: `upgrade`)

| Step | Status |
|------|--------|
| Rails 5.1 → 5.2 | ✅ done |
| Foundation gem → vendored SCSS | ✅ done |
| paperclip → kt-paperclip | ✅ done (Gemfile) |
| Ruby 3.x | not yet |
| Rails 6.1 | not yet |
| Browserify → esbuild/importmap | not yet |
| React 0.14 → 18 | not yet |
| Paperclip → ActiveStorage | not yet (kt-paperclip bridges) |

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
aws-sdk < 2.0 is kept for S3 compatibility.

Models using attachments:
- `app/models/bakery.rb` — `has_attached_file :logo`
- `app/models/file_export.rb` — `has_attached_file :file`

## JavaScript (Browserify era — pre-upgrade)

JS is bundled via `browserify-rails 4.3.0`. Entry point: `app/assets/javascripts/app.js`.
Babel 6 transpiles JSX + ES2015.

**Do not touch JS bundling** until the CSS/Rails upgrade is stable. The Browserify → esbuild migration is a separate workstream.

Vendor CSS copied manually (do not overwrite from npm):
- `app/assets/stylesheets/vendor/chosen.css`
- `app/assets/stylesheets/vendor/react-datepicker.css`
- `app/assets/stylesheets/vendor/react-select.css`
- `app/assets/stylesheets/vendor/jquery_ui.scss`

## Specs

Test framework: RSpec. Factories: FactoryBot (`spec/support/factory_girl.rb` is a shim that requires factory_bot_rails).

Run all specs: `docker-compose run web bundle exec rspec`
Run one spec: `docker-compose run web bundle exec rspec spec/models/bakery_spec.rb`

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
| Shipment / ShipmentItem | delivery tracking |
| FileExport | background-generated file with S3 attachment |

## Background jobs

Resque-based. Worker: `ResqueWorker`. Jobs live in `app/jobs/`.
Redis connection: `REDIS_URL` env var (defaults to `redis://localhost:6379/1`).

## Known pain points for future upgrade hops

- `active_model_serializers 0.9.3` — ancient; 0.10.x has breaking DSL changes. Defer until Rails 6+.
- `browserify-rails` — incompatible with Rails 7+. Replace with `jsbundling-rails` + esbuild at Rails 7 hop.
- `rubyzip 1.0.0` — pinned; v2 has breaking API changes. Audit usages before bumping.
- `aws-sdk < 2.0` — SDK v1; must replace before Rails 7 era. kt-paperclip 7.x uses aws-sdk-s3.
- `resque` — Solid Queue is Rails 8 default. Resque still works; migrate when convenient.
- `axlsx 2.0.1` — community successor is `caxlsx`. Check compatibility before Rails 7.
- `devise-async` git fork — non-standard. Can be replaced with native ActiveJob delivery in Rails 6+.
- `jquery-rails` — jQuery not needed for Rails 7 UJS (which uses vanilla JS). Remove at Rails 7 hop.
