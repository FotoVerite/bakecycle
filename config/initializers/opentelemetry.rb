# frozen_string_literal: true

# Everything below (SDK.configure, Common::Utilities, the Solid
# Queue/Cable polling suppression) needs the actual SDK, not just the API --
# opentelemetry-api alone is now loaded in every environment (Gemfile,
# "all environments" comment) so plain `defined?(OpenTelemetry)` is true in
# test/development too, but opentelemetry-sdk itself stays production/staging
# only. Guard on the SDK constant specifically or this raises on boot
# anywhere the SDK isn't bundled.
return unless defined?(OpenTelemetry::SDK)

# Solid Queue's Worker/Dispatcher and Solid Cable's Listener each poll on a
# fixed timer regardless of real traffic (confirmed via Honeycomb: ~99.98%
# of daily span volume was this polling, not real traffic). An earlier
# attempt filtered these out post-hoc at export time by matching db.statement
# against the polling table names, but that only caught the SELECT/EXECUTE
# span -- the surrounding transaction's BEGIN/COMMIT spans have no table name
# in their db.statement, so they kept exporting at full rate.
#
# Both gems already funnel every poll through a single `with_polling_volume`
# method (Solid Queue: SolidQueue::Processes::Poller; Solid Cable:
# ActionCable::SubscriptionAdapter::SolidCable::Listener), so instead of
# reconstructing "which spans belong to a poll" after the fact, we suppress
# span creation at the source for the duration of that call. OpenTelemetry's
# own untraced context is checked by the SDK's TracerProvider itself (not
# instrumentation-specific), so it also covers the BEGIN/COMMIT spans the
# nested ActiveRecord/pg calls generate.
module OpenTelemetryPollingSuppression
  def with_polling_volume(&block)
    OpenTelemetry::Common::Utilities.untraced { super(&block) }
  end

  # Solid Queue's process heartbeat (SolidQueue::Processes::Registrable,
  # mixed into every process type via Base) is a second, independent noise
  # source -- a Concurrent::TimerTask firing every process_heartbeat_interval
  # (60s default) per running process, unrelated to with_polling_volume.
  # Measured via Honeycomb at ~20k spans/day, ~150x smaller than the poller
  # noise above but the same "fixed timer, not real traffic" shape.
  def heartbeat
    OpenTelemetry::Common::Utilities.untraced { super }
  end
end

SolidQueue::Processes::Poller.prepend(OpenTelemetryPollingSuppression)

# Registrable is included into SolidQueue::Processes::Base (and so into every
# process subclass -- Poller, Worker, Dispatcher, Supervisor) before this
# initializer runs, but prepending onto the module here still takes effect
# for those already-including classes: `include` keeps a live reference to
# the module, so prepending into it afterwards still resolves ahead of it in
# the ancestor chain. Confirmed via `rails runner` in RAILS_ENV=staging.
SolidQueue::Processes::Registrable.prepend(OpenTelemetryPollingSuppression)

require "action_cable/subscription_adapter/solid_cable"
ActionCable::SubscriptionAdapter::SolidCable::Listener.prepend(OpenTelemetryPollingSuppression)

# Honeycomb's model is query-first: wide events with full request context,
# sliced/grouped ad hoc after the fact (BubbleUp), not a pre-curated set of
# spans decided in advance. use_all auto-instruments every supported gem
# present (Rack, ActionPack, ActiveRecord/pg, ActionView, Net::HTTP, etc.) so
# that data is actually available to query later.
OpenTelemetry::SDK.configure do |c|
  c.service_name = "bakecycle-#{Rails.env}"
  c.use_all
end
