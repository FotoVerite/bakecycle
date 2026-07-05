return unless defined?(Sentry)

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"].presence || Rails.application.credentials.dig(:sentry, :dsn)

  config.environment = Rails.env
  config.enabled_environments = %w[production staging]

  config.breadcrumbs_logger = %i[
    active_support_logger
    http_logger
  ]

  config.send_default_pii = false

  config.traces_sample_rate = 1.0
end

# Solid Queue's worker pool keeps a small, fixed number of threads alive for
# the whole worker process lifetime (config/queue.yml: threads: 3) and reuses
# each thread across many jobs, rather than spawning one thread per job.
# Sentry.get_current_hub only clones a fresh hub onto a thread the *first*
# time that thread ever touches Sentry -- every job run afterward on that
# same long-lived thread reuses whatever hub/scope state was left over from
# the previous job, instead of starting clean. Confirmed on staging: a
# ExporterJob run produced no Sentry transaction despite completing
# successfully, and journalctl showed an unrelated concurrently-run job's log
# tag bleeding into ExporterJob's -- evidence of stale thread-local state on a
# reused worker thread, not a code failure in the job itself.
#
# Forcing a fresh hub clone at the start of every job (matching what
# Sidekiq's official Sentry integration does) gives every job a guaranteed
# clean scope regardless of what ran on that thread before.
ActiveSupport.on_load(:active_job) do
  around_perform do |_job, block|
    Sentry.clone_hub_to_current_thread if defined?(Sentry) && Sentry.initialized?
    block.call
  end
end
