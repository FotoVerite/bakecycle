# Bakecycle — Agent Context

Bakery operations SaaS app. Rails 8 + Stimulus/Turbo + PostgreSQL. React was fully removed.

**Real-world usage note:** the app was built as multi-tenant SaaS (`Bakery` is the tenant root — see "Key models" below) and that architecture is still real and still matters for correctness. But in practice, **Bien Cuit — the bakery that commissioned/created the app — is effectively the only real tenant.** In the dev DB snapshot, Bien Cuit alone accounts for 76,237 of 76,580 total orders (99.6%) across 20 bakery records; the other 19 are legacy/test/demo accounts with single-digit-to-low-hundreds order counts. Practical implications:
- Multi-tenant correctness bugs (e.g. a query that doesn't scope by `bakery_id`) are still real bugs worth fixing, but they will almost never show up as a *performance* problem in practice — Bien Cuit's own row count already dominates any query, so scoping by bakery rarely shrinks what gets scanned for the tenant that actually generates load.
- Don't assume "there are many bakeries with meaningfully-sized datasets" when reasoning about scale — there is effectively one, and it's already the whole dataset.
- Any specific-to-Bien-Cuit business rule you find hardcoded or asymmetric in the app (naming conventions, workflow assumptions) is more likely a deliberate reflection of the one real customer's process than a bug.

## How to run

Runs natively on Ruby 3.3.1 (arm64-darwin). No Docker required for development.

```bash
bundle exec rails server          # start app
bundle exec rspec                 # run all specs
bundle exec rspec spec/models/bakery_spec.rb  # run one spec
bundle exec rails db:migrate
```

PostgreSQL must be running locally (e.g. via Homebrew services). No Redis dependency anywhere in the app — Solid Queue and Solid Cable are both DB-backed, using the primary Postgres database.

## Dev preview login

Browser-based verification hits the Devise sign-in wall; never reset a real user's password to get past it. A dedicated preview user exists in the dev DB: `impeccable-preview@example.com` / `PreviewPass123!` (all six `*_permission` columns set to `manage`, attached to the first bakery). If it's missing, recreate it via `rails runner` with those credentials. When verifying CSS values, prefer `preview_inspect`/computed styles over screenshots — the screenshot tool's scaling is unreliable.

## Verification policy — read before running specs/preview server

Don't run the full test suite, start the preview server, or do browser-based
verification by default after a change. It's expensive and low-signal for
most edits. Only do it when:
- The change is genuinely hard to verify by reading the code/diff (complex
  async/timing behavior, a bug that only reproduces at runtime).
- The user explicitly asks for verification.
- It's a UI/CSS change where visual regression is the actual risk (layout,
  contrast, responsive behavior).

For everything else — config fixes, backend logic, refactors covered by
existing specs, mechanical multi-file edits — read the code and relevant
specs, run only the narrowly-scoped spec file(s) that exercise the change if
needed, and state your confidence. Don't reach for a browser or the full
suite to "be sure."

## Stack

- **Ruby** 3.3.1 (arm64-darwin, native — not Docker)
- **Rails** 8.1.3
- **DB** PostgreSQL (local)
- **Background jobs** Solid Queue (DB-backed, no Redis dependency).
- **Action Cable** Solid Cable (DB-backed, `config/cable.yml`) — no Redis dependency. All three environments (development/staging/production) use it; only `test` uses the plain `test` adapter.
- **Asset pipeline** Propshaft + jsbundling-rails (JS via esbuild) + cssbundling-rails (CSS via Dart Sass). **Important:** the dev server serves the *built* files (`app/assets/builds/application.css`, `app/assets/builds/bakecycle.js`), not live-compiled source — see "Asset build gotcha" below.
- **CSS** Foundation 5.5 (vendored — see below)
- **JS** Stimulus + Turbo (`@hotwired/turbo`, `turbo-rails` gem). React/Redux fully removed.

The multi-year upgrade (Rails 5.1→8.1, Ruby 2.5→3.3, React→Stimulus, Resque→Solid Queue) is **complete**; history lives in agent memory, not here. Two standing decisions survive it: **never migrate kt-paperclip→ActiveStorage** (kt-paperclip is actively maintained; deliberate choice), and **`stripe < 6` stays pinned** (don't bump without a dedicated audit).

## Framework gotchas

- Zeitwerk is active; report classes live flat in `app/reports/`. `config/boot.rb` requires `"logger"` explicitly.
- Turbo Drive is active app-wide; use `data: { turbo_method: :delete }`, never `link_to method:`.
- **Devise + Turbo gotcha:** `config/initializers/devise.rb` sets `config.responder.error_status = :unprocessable_entity` and `config.responder.redirect_status = :see_other`. Without these, Devise's failure app returns form re-renders with HTTP `200` and Turbo throws `"Form responses must redirect to another location"` on every failed login. **Do not remove them.**
- **YAML safe-load gotcha:** `ActiveRecord.yaml_column_permitted_classes` defaults to `[Symbol]` only. A YAML-serialized column holding `BigDecimal`/`Date`/`Time` (e.g. PaperTrail's `versions.object_changes`) silently deserializes to `{}`/`nil` — no error raised. `config/initializers/paper_trail.rb` extends the permitted list; check it before assuming "no changes" means "nothing changed."

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

**`config.active_job.queue_adapter` must be set in `config/application.rb`, not in `config/initializers/*`** — `on_load(:active_job)` fires before app initializers, so an initializer setting is silently a no-op and every job falls back to the in-process `:async` adapter with no error.

**Never use `bin/jobs` locally — use `bin/jobs-dev`.** Solid Queue's forking `Supervisor` segfaults on this machine (forking with an open `pg` connection corrupts it). `bin/jobs-dev` is a non-forking thread-only worker; `Procfile`/`Procfile.dev` both use it. Staging/production keep `bin/jobs`.

**`command:`-based tasks in `config/recurring.yml` need an explicit `queue:`** — without one they enqueue to Solid Queue's internal `solid_queue_recurring` queue, which no worker group in `config/queue.yml` listens to, and sit `ready` forever.

Recurring jobs: `clear_solid_queue_finished_jobs` (hourly; successful-job history), `clear_solid_queue_failed_jobs` (hourly; no jobs configure `retry_on`, so failed executions never retry and must be pruned), `purge_old_versions` (daily 3am; 90-day PaperTrail retention), plus kickoff/digest jobs.

## PaperTrail (audit trail)

Tracked models: `OrderItem`, `Product`, `PriceVariant`, `Recipe`, `RecipeItem`. Per-record history is viewable at `/products/:id/papertrail`, `/recipes/:id/papertrail`, `/orders/:id/papertrail` (controller actions + views named `papertrail`), rendered via the shared `shared/_papertrail_timeline` partial. Styling lives in `app/assets/stylesheets/app/_papertrail.scss`.

**Retention:** `PurgeOldVersionsJob` runs daily, deleting `versions` rows older than 90 days in batches (`versions.created_at` is indexed). One-off backlog task: `rake versions:purge_order_item_backlog`.

**`OrderItem` deliberately uses `on: %i[create update destroy]` (no `:touch`)** — `Product#queue_touch_order_items` touches every order item on relevant product saves; with default touch-tracking that once generated ~64M rows of empty-`object_changes` noise. If you add `has_paper_trail` to a model that gets `.touch`ed by another model's callback, exclude `:touch` for the same reason.

**Don't assume "no changes shown" means PaperTrail is broken** — check the YAML safe-load gotcha (Framework gotchas above) first.

## Known pain points

- `active_model_serializers 0.10` — API response shape has no spec coverage; verify JSON in-browser after touching serializers.
- `aws-sdk-s3` (via kt-paperclip) — uploads/downloads not covered by specs; verify S3 in staging before major changes.
- **Staging/production `versions` table** — the 64M-row PaperTrail backlog was cleared locally; check table size on the servers before assuming it's gone there too.
- `jquery-rails` — still needed for jquery-timepicker and jquery-ui-sass-rails; removable once those widgets get native/Stimulus replacements.
- `config/deploy/production.rb` — `worker_service_units` still points at `resque.service`; needs the real Solid Queue systemd unit name before the next production deploy.

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
| `$bc-silver-chalice` | `#a0a0a0` | **Avoid for text** — ~2.3:1 on white/off-white, fails WCAG AA; use `$bc-scorpion`. Same trap: white text on `$bc-shakespeare` at default lightness is ~2.3:1 — darken the bg (existing avatars use `color.adjust(..., $lightness: -20%)`). Check contrast on any new white-on-color badge. |

Font: **Open Sans** (300/400/600/700/800), self-hosted via `base/font_setup.scss`.
