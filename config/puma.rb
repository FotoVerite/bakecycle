threads_count = ENV.fetch("RAILS_MAX_THREADS", 6).to_i
threads 1, threads_count

rails_env = ENV.fetch("RAILS_ENV", "development")
workers_count = ENV.fetch("WEB_CONCURRENCY") do
  rails_env == "production" ? 2 : 0
end.to_i

workers workers_count if workers_count.positive?
preload_app! if workers_count.positive?

app_dir = File.expand_path("..", __dir__)
shared_dir = "#{app_dir}/../../shared"

environment rails_env

if %w[production staging].include?(rails_env)
  # Set up socket location
  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # Set master PID and state locations
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"
  activate_control_app

  on_worker_boot do
    ActiveRecord::Base.establish_connection
  end
else
  port ENV.fetch("PORT", 3000)
end
