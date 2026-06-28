# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"

  config.force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"

  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.new(
    ActiveSupport::BroadcastLogger.new(
      ActiveSupport::Logger.new($stdout),
      ActiveSupport::Logger.new(Rails.root.join("log/staging.log"))
    )
  )
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"

  config.active_support.report_deprecations = false

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {
    protocol: "https",
    host: "staging.bakecycle.com"
  }

  config.i18n.fallbacks = true

  ActionMailer::Base.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: "587",
    authentication: :plain,
    user_name: ENV["SENDGRID_USERNAME"],
    password: ENV["SENDGRID_PASSWORD"],
    domain: "staging.bakecycle.com",
    enable_starttls_auto: true
  }

  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]
end
