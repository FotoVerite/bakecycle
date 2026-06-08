# Pre-Rails 8 Audit

Current: Rails 7.1.6, Ruby 3.3.1. Target: Rails 8.0.

Three categories: **breaking** (will error on Rails 8), **risk** (won't explode but will cause pain), **simplify** (clean up before the noise gets louder).

---

## Breaking — Fix Before Upgrading

### 1. `config.active_support.deprecation` removed in Rails 8
The `active_support.deprecation = :log/:notify` config key was deprecated in 7.1 and **removed in Rails 8**. It exists in all four environment files.

**Fix** — replace in `development.rb`, `test.rb`, `production.rb`, `staging.rb`:
```ruby
# remove:
config.active_support.deprecation = :log

# replace with:
config.active_support.report_deprecations  # raises in test, logs in dev, notifies in prod
```

### 2. Stripe.js v2 + stripe gem pinned `< 6`
`credit_card_form.js` uses `Stripe.card.createToken()` — the Stripe.js v2 API that Stripe officially shut down in 2024. The gem is pinned `< 6` (current is v13). This is both a **breaking issue and a PCI compliance risk** — card data is being handled client-side in a way Stripe no longer supports.

**Fix** (dedicated task, not a quick change):
- Migrate `credit_card_form.js` to Stripe.js v3 + Stripe Elements
- Bump stripe gem to `~> 13.0`
- Update `StripeUserCreateJob` and `RegistrationsController` for v13 API changes
- Update `stripe-ruby-mock` to matching version
- Test the full registration flow in staging

### 3. `method: :delete` UJS links — 21 instances
These work now with `rails-ujs`. Rails 8 includes Turbo by default; `method:` links will be intercepted by Turbo and break. Need to convert before or immediately after upgrading.

**Fix** — global find-and-replace in views:
```erb
# from:
<%= link_to "Delete", thing_path(thing), method: :delete %>

# to:
<%= link_to "Delete", thing_path(thing), data: { turbo_method: :delete } %>
```
Also update `shipments/_double_shipment.html.erb` (`remote: true` → `data: { turbo_stream: true }`).

---

## Risk — Should Fix Before Upgrading

### 4. Resque + Redis (no background workers in dev)
Rails 8 ships Solid Queue (DB-backed, no Redis needed). Resque still works on Rails 8 but:
- Requires Redis running in production alongside Postgres — another moving part to maintain
- Current dev setup has no Resque worker running, which means the "no resque workers" flash appears on every page load in development
- `capistrano-resque` deploy plugin is barely maintained

**Recommendation:** Migrate to Solid Queue. It's a drop-in for `ActiveJob`-based jobs. `DemoCreatorJob`, `StripeUserCreateJob`, and `ExporterJob` all use `ApplicationJob < ActiveJob::Base`, so they'll work automatically. The `ResqueJobs` concern (used in `Product` and `Recipe` for background touches) uses `Resque.enqueue` directly — that's the only part needing a rewrite.

**Migration path:**
```bash
bundle add solid_queue
rails solid_queue:install
# Remove: resque, capistrano-resque, redis (if unused elsewhere)
```

### 5. `active_model_serializers 0.10` — effectively abandoned
AMS hasn't had a meaningful release since 2019. It works on 7.1 but Rails 8 compatibility is untested by maintainers. Currently used only in `api/file_exports_controller.rb` (for `render json: @file_export`). Every other JSON response in the app uses `.to_json` or `as_json` directly.

**Fix** — delete the one serializer (`app/serializers/file_export_serializer.rb`), replace with `render json: @file_export.as_json(only: [...], methods: [...])`, remove the gem and its initializer.

### 6. `jquery-timepicker-rails` + `jquery-ui-sass-rails` — 32 `.js-datepicker` usages
These are the last things keeping jQuery in the Gemfile. All 32 usages are `<input class="js-datepicker">` on date fields. Native `<input type="date">` has been supported in all major browsers since 2019 and renders a native picker.

**Fix** — replace jQuery UI datepicker with `<input type="date">`:
- Remove `class: "js-datepicker"` from all 32 input fields
- Use `as: :date` in SimpleForm or `type: "date"` in raw inputs
- Remove `jquery-timepicker-rails` and `jquery-ui-sass-rails` from Gemfile
- Remove `jquery-rails` if nothing else needs it (check `foundation.js` and `clickable-row.js`)
- This also cleans up the vendored jQuery UI SCSS we just added

### 7. `force_ssl` commented out in production
```ruby
# config/environments/production.rb
# config.force_ssl = true   ← uncomment this
```
Independent of Rails 8 but a security gap. Rails 8 also adds `config.assume_ssl = true` for setups behind a load balancer that terminates SSL.

---

## Test Gaps — Fill Before Upgrading

676 specs, 0 failures — good baseline. But coverage is uneven.

### 8. 15 controllers with zero request specs
No specs at all for: `batch_recipes`, `buy_orders`, `costing`, `daily_totals`, `dashboard`, `delivery_lists`, `file_actions`, `file_exports`, `landing_pages`, `packing_slips`, `production_checklists`, `public_client_users`, `registrations`, `reports`, `robots`.

These are the controllers most likely to break silently on an upgrade. Minimum useful coverage: auth redirect (unauthenticated → login), happy-path index/show, and any destructive actions.

### 9. 7 empty pending specs
`ingredient_prices_over_time_spec.rb`, `file_action_spec.rb`, `public_client_user_spec.rb`, `vendor_spec.rb`, `product_graph_datum_spec.rb`, `buy_order_spec.rb` — all stubs with `# add some examples`. Either write them or delete the files. They inflate the spec count and mask real gaps.

### 10. S3 / file attachment flow untested
`kt-paperclip` with S3 is not covered by any spec. `WebMock` is in the test group but S3 upload/download isn't stubbed anywhere. Before upgrading (or before any Paperclip → ActiveStorage migration), manually verify file upload and download in staging. Add at least a smoke test.

### 11. API JSON response shape unverified
`api/v1/orders_controller` and `api/v1/accounts_controller` have request specs but they don't assert response JSON shape. If anything external consumes this API, shape regressions will be invisible. Add `expect(json["key"]).to eq(...)` assertions.

---

## Simplify — Lower Priority but Clean Up

### 12. `chronic` gem — 4 usages, replaceable
Used for parsing "4 pm" into a time (bakery kickoff default) and fuzzy date parsing in search. Could be replaced with `Time.zone.parse` for the defaults and `Date.parse` with a rescue for search. Not blocking but adds a dependency for minimal value.

### 13. Bullet gem — configured but silent
`bullet` is in the Gemfile but `config/environments/development.rb` has no Bullet config. It's doing nothing. Either configure it or remove it:
```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.rails_logger = true
end
```
Running it for a session across the main pages will probably surface several N+1s worth fixing before the new features go in.

### 14. `draper` — used everywhere, works fine, but adds indirection
`decorates_assigned` is called in 10 controllers. Draper is maintained and works, but it's an extra layer for what's mostly string formatting. Not urgent — but if you ever find yourself fighting it during the new feature work, it's worth knowing the pattern can be simplified to plain model methods or helpers.

### 15. `will_paginate` → Pagy (optional)
`will_paginate` is older and slower than Pagy. Not a Rails 8 blocker, but Pagy is now the de facto standard and is much lighter. Worth swapping if you're already touching pagination-heavy controllers.

---

## Recommended Order

| # | Task | Effort | Must-do? |
|---|------|--------|----------|
| 1 | Fix `active_support.deprecation` config | 15 min | Yes |
| 3 | Convert 21 `method: :delete` links to Turbo | 1 hr | Yes |
| 5 | Remove `active_model_serializers` | 2 hrs | Yes |
| 4 | Migrate Resque → Solid Queue | 1–2 days | Strongly recommended |
| 6 | Replace jQuery datepicker with native `<input type="date">` | 0.5 days | Strongly recommended |
| 7 | Uncomment `force_ssl` | 5 min | Yes |
| 2 | Stripe.js v2 → v3 migration | 2–3 days | Yes (compliance) |
| 8 | Request specs for untested controllers | 2–3 days | Recommended |
| 9 | Delete/fill 7 empty specs | 1 hr | Yes (hygiene) |
| 10 | S3 smoke tests in staging | Manual | Before any Paperclip→ActiveStorage work |
| 13 | Configure Bullet | 30 min | Recommended |
