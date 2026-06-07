Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.static_cache_control = "public, max-age=31536000"
  config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"

  config.force_ssl = true

  config.log_level = :info

  config.i18n.fallbacks = true

  config.log_formatter = ::Logger::Formatter.new

  config.active_record.dump_schema_after_migration = false

  ActionMailer::Base.smtp_settings = {
    address: "smtp.sendgrid.net",
    port: "587",
    authentication: :plain,
    user_name: ENV["SENDGRID_USERNAME"],
    password: ENV["SENDGRID_PASSWORD"],
    domain: "staging.bakecycle.com",
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = {
    protocol: "https",
    host: "staging.bakecycle.com"
  }
end
