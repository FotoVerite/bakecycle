# Bakecycle — Agent Context

Bakery operations SaaS app. Rails + Turbo/Stimulus + PostgreSQL.

## How to run

Use the local Ruby/Node/PostgreSQL setup for this project.

```bash
bundle install
yarn install
bin/rails db:migrate
bin/dev
```

Run specs locally:

```bash
bundle exec rspec
bundle exec rspec spec/models/bakery_spec.rb
```

## Stack

- **Ruby** 3.3.1 (`.ruby-version`)
- **Rails** ~> 8.0
- **DB** PostgreSQL
- **Background jobs** Solid Queue
- **Asset pipeline** Propshaft + Dart Sass + jsbundling-rails/esbuild
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** Turbo + Stimulus, bundled with esbuild

## Upgrade status (branch: `upgrade`)

| Step | Status |
|------|--------|
| Rails 5.1 → 5.2 | ✅ done |
| Foundation gem → vendored SCSS | ✅ done |
| paperclip → kt-paperclip | ✅ done |
| Ruby 3.x | ✅ done |
| Rails 8.0 | ✅ done |
| Browserify → esbuild | ✅ done |
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

Switched from `paperclip` to `kt-paperclip ~> 7.0` (drop-in API replacement).
S3 storage config is in `config/initializers/paperclip.rb`.

Models using attachments:
- `app/models/bakery.rb` — `has_attached_file :logo`
- `app/models/file_export.rb` — `has_attached_file :file`

## JavaScript

JS is bundled via esbuild. Entry point: `app/assets/javascripts/app.js`.

Vendor CSS copied manually (do not overwrite from npm):
- `app/assets/stylesheets/vendor/chosen.css`
- `app/assets/stylesheets/vendor/react-datepicker.css`
- `app/assets/stylesheets/vendor/react-select.css`
- `app/assets/stylesheets/vendor/jquery_ui.scss`

## Specs

Test framework: RSpec. Factories: FactoryBot (`spec/support/factory_girl.rb` is a shim that requires factory_bot_rails).

Run all specs: `bundle exec rspec`
Run one spec: `bundle exec rspec spec/models/bakery_spec.rb`

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

Solid Queue-based. Jobs live in `app/jobs/`. In local development, use `bin/jobs-dev` or `bin/dev`.

## Known pain points for future upgrade hops

- ActiveStorage migration remains future work; kt-paperclip is still the bridge.
- `jquery-rails` remains in the app; audit before removing.
