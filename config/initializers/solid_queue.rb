# frozen_string_literal: true

# NOTE: queue_adapter is set in config/application.rb, not here. Something
# (a gem, autoloaded job class, etc.) triggers ActiveJob's lazy on_load hook
# before config/initializers/* runs, which bakes in whatever
# config.active_job.queue_adapter was set to at that point -- setting it here
# was silently too late and left every job running on the :async fallback
# adapter (in-process thread pool, falls back to executing inline on the
# caller's thread when the pool is busy) instead of Solid Queue. Confirmed via
# `ActiveJob::Base.queue_adapter.class` returning AsyncAdapter despite this
# line reading :solid_queue -- that's what made exports block the request for
# the full generation+upload time instead of returning immediately.

MissionControl::Jobs.http_basic_auth_enabled = false
