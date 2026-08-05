# frozen_string_literal: true

# Pre-cutover deployment target for the new production host. The existing
# `production` stage remains pointed at the live server until migration.
set :deploy_to, "/var/www/bakecycle_next_production"
set :user, "deploy"
set :branch, "master"
set :puma_service_unit, "bakecycle-next-production-puma.service"
set :worker_service_units, %w[bakecycle-next-production-solid-queue.service]
set :ssh_options, forward_agent: true, port: 22
set :bundle_command, "/usr/bin/mise exec ruby@4.0.6 -- bundle"
set :default_env, {
  path: "/home/deploy/.local/share/mise/shims:/home/deploy/.local/bin:/usr/local/bin:/usr/bin:/bin"
}

append :linked_files,
       "config/credentials/production.yml.enc",
       "config/credentials/production.key"

role :app, %w[deploy@96.126.110.82]
role :web, %w[deploy@96.126.110.82]
role :db, %w[deploy@96.126.110.82]
