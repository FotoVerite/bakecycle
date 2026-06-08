# frozen_string_literal: true

Rails.application.configure do
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?

  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = :none

  config.action_controller.allow_forgery_protection = false
  config.action_controller.action_on_unpermitted_parameters = :raise
  config.action_controller.raise_on_missing_callback_actions = true

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.active_support.deprecation = :stderr

  config.after_initialize do
    Bullet.enable                      = true
    Bullet.raise                       = true
    Bullet.unused_eager_loading_enable = false
  end
end
