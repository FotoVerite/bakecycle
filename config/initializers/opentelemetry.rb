# frozen_string_literal: true

return unless defined?(OpenTelemetry)

# Honeycomb's model is query-first: wide events with full request context,
# sliced/grouped ad hoc after the fact (BubbleUp), not a pre-curated set of
# spans decided in advance. use_all auto-instruments every supported gem
# present (Rack, ActionPack, ActiveRecord/pg, ActionView, Net::HTTP, etc.) so
# that data is actually available to query later.
OpenTelemetry::SDK.configure do |c|
  c.service_name = "bakecycle-#{Rails.env}"
  c.use_all
end
