# frozen_string_literal: true

set :deploy_to, "/home/deploy/apps/bakecycle_staging"
set :user, "deploy"
set :branch, ENV.fetch("BRANCH", `git rev-parse --abbrev-ref HEAD`.chomp)
set :rails_env, "staging"
set :rack_env, "staging"
set :default_env, {
  "PATH" => "/home/deploy/.local/share/mise/shims:/home/deploy/.local/bin:/usr/local/bin:/usr/bin:/bin",
  "RAILS_ENV" => "staging",
  "RACK_ENV" => "staging"
}
set :ssh_options, forward_agent: true
set :puma_service_unit, "bakecycle-staging-puma.service"
set :solid_queue_service_unit, "bakecycle-staging-solid-queue.service"
set :workers, "*" => 2

append :linked_files, "config/credentials/staging.key"

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
server "23.239.9.198", user: "deploy", roles: %w[app web db], primary: true
