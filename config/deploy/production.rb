# frozen_string_literal: true

# Live production. The pre-cutover Linode (97.107.141.39, SSH port 21500) was
# retired in Aug 2026 -- this host has served all traffic since ~2026-08-14 and
# is the only production database. Nothing should reference the old box.
set :deploy_to, "/var/www/bakecycle_next_production"
set :user, "deploy"
set :branch, "production"
set :puma_service_unit, "bakecycle-next-production-puma.service"
set :worker_service_units, %w[bakecycle-next-production-solid-queue.service]
set :ssh_options, forward_agent: true, port: 22
set :default_env, {
  path: "/home/deploy/.local/share/mise/shims:/home/deploy/.local/bin:/usr/local/bin:/usr/bin:/bin"
}

append :linked_files,
       "config/credentials/production.yml.enc",
       "config/credentials/production.key"

role :app, %w[deploy@96.126.110.82]
role :web, %w[deploy@96.126.110.82]
role :db, %w[deploy@96.126.110.82]
