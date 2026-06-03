# Upgrade Suggestions

Ordered roughly from lowest complexity to highest complexity.

## 1. Remove Spring

Spring is no longer useful here and causes macOS fork-safety crashes.

- Remove `spring`
- Remove `spring-commands-rspec`
- Keep `bin/rails` and `bin/rspec` free of Spring loading

## 2. Remove Unused Development Gems

Audit these before removing, but they are likely low-value now:

- `guard-livereload`
- `guard-rails`
- `rack-livereload`
- `launchy`
- `immigrant`
- `rails-erd`

Keep anything still used by the team, but avoid carrying old dev tooling through each Rails hop.

## 3. Clean Up Test Helpers

Prefer Rails/RSpec-native helpers where possible.

- Replace `timecop` with `ActiveSupport::Testing::TimeHelpers`
- Review whether `database_cleaner` is still needed or if transactional fixtures are enough
- Keep `factory_bot_rails`, `faker`, `webmock`, `rspec-rails`, and `shoulda-matchers`

## 4. Replace XLSX Gems

The current spreadsheet stack is old:

- `axlsx 2.0.1`
- `axlsx_rails`
- `rubyzip 1.0.0`

Suggested replacement:

- `caxlsx`
- `caxlsx_rails`

This app generates many XLSX reports, so do this as a focused report migration with report specs around generated files.

## 5. Remove Uglifier

Once JavaScript is bundled by esbuild, remove `uglifier`.

esbuild can handle production minification, and keeping Uglifier only preserves an old Sprockets-era assumption.

## 6. Replace Browserify With Esbuild

Current stack:

- `browserify-rails`
- Browserify
- Babel 6
- `npm-shrinkwrap.json`
- `app/assets/javascripts/app.js`

Suggested replacement:

- `jsbundling-rails`
- esbuild
- modern `package-lock.json` or another current lockfile
- `app/javascript/application.js`
- output to `app/assets/builds`

This should happen before React upgrades. Keep Sprockets temporarily for stylesheets, images, and vendored Foundation assets.

## 7. Replace Legacy jQuery Plugins

Current legacy plugins:

- Chosen
- jQuery UI datepicker
- jQuery timepicker
- jQuery UJS

Suggested replacements:

- Chosen -> `tom-select`, or native selects where simple
- jQuery datepicker/timepicker -> `flatpickr`, or native date/time inputs where acceptable
- jQuery UJS -> Rails unobtrusive helpers replacement, Turbo, or explicit fetch/form handling depending on the page

Do this one plugin at a time after esbuild is in place.

## 8. Modernize React

Current stack:

- React `0.14`
- ReactDOM `0.14`
- `create-react-class`
- React Redux `4`
- Redux `3`
- React Select `1.0.0-beta`
- React Datepicker `0.23`

Suggested path:

- Move bundling to esbuild first
- Upgrade React in stages
- Replace `create-react-class` with function components
- Upgrade `react-select` and `react-datepicker`
- Replace Redux stores with Redux Toolkit only where shared state is still useful
- Remove Backbone stores once their forms/components are converted

This is a larger UI project, not a Rails compatibility patch.

## 9. Replace Moment

Moment is used in a few order/date components and is heavier than necessary.

Suggested replacements:

- `date-fns`
- native `Intl` and `Date` APIs where simple

Do this after the bundler migration so imports and tree-shaking work normally.

## 10. Replace Devise Async

Current:

- `devise-async` from a git fork

Suggested replacement:

- normal Devise mailers
- `deliver_later`
- Active Job queue backend

This removes a non-standard dependency before later Rails upgrades.

## 11. Modernize Stripe

Current:

- `stripe < 6`
- Stripe.js v2 token flow
- `stripe-ruby-mock`

Suggested replacement:

- current Stripe gem
- Stripe.js current integration
- Payment Intents or Setup Intents as appropriate
- WebMock/request stubs instead of relying on old Stripe mock behavior

Treat this as a billing-specific project because it touches registration, customer creation, tests, and frontend tokenization.

## 12. Replace Paperclip With Active Storage

Current:

- `kt-paperclip`
- `Bakery#logo`
- `FileExport#file`
- S3 Paperclip initializer

Suggested replacement:

- Active Storage
- direct S3 service configuration
- updated serializers/decorators for file URLs
- migration for existing attachment records and S3 keys

Usage is limited, which helps, but this still needs a dedicated migration plan.

## 13. Move From Resque Toward Solid Queue

Current:

- Resque
- Redis
- Resque web UI
- custom `Resque::TermException` retry behavior

Suggested path:

- Keep Resque during the Rails 6 stabilization work
- Later evaluate Solid Queue when moving toward Rails 8
- Replace Resque-specific exception/re-enqueue logic with Active Job retry/discard behavior

Do this after the app is stable on newer Rails and background job behavior is well covered.

## 14. Move From Sprockets To Propshaft

Rails 8 defaults new apps to Propshaft, but this app still has Sprockets-era assumptions:

- SCSS imports
- vendored Foundation 5 CSS
- Sprockets manifests
- asset helper behavior around fonts/SVGs

Suggested path:

- First migrate JS to esbuild
- Then migrate CSS compilation to Dart Sass or `cssbundling-rails`
- Keep vendored Foundation CSS until the UI framework is replaced
- Move to Propshaft after assets are already browser-ready

Do not combine this with the Browserify or React migration.

## 15. Replace Foundation 5

Foundation 5 is vendored and deeply embedded in the views.

Common classes include:

- `row`
- `columns`
- `small-12`
- `medium-*`
- `large-*`
- `panel`
- `alert-box`
- `button`
- `label`
- Foundation icon classes

Suggested replacement:

- Keep it vendored short-term
- Replace page-by-page or component-by-component
- Prefer a modern CSS system only after the Rails/JS asset stack is stable

This is the largest frontend/design migration and should not block Rails 6 or Rails 7 compatibility.
