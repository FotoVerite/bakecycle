# frozen_string_literal: true

return unless defined?(OpenTelemetry)

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
end

SolidQueue::Processes::Poller.prepend(OpenTelemetryPollingSuppression)

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
