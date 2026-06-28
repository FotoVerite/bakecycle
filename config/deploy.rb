# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.20"

set :application, "bakecycle"
set :repo_url, "git@github.com:fotoverite/bakecycle.git"
set :ssh_options, forward_agent: true

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'

set :format, :pretty
# set :log_level, :debug
set :pty, true

set :linked_files, %w[.env config/database.yml]
set :linked_dirs, %w[
  log tmp/pids tmp/cache
  tmp/sockets vendor/bundle
  public/images public/system
  public/pdfs node_modules
]
set :bundle_binstubs, nil
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5
set :puma_service_unit, "puma.service"
set :worker_service_units, []

namespace :app do
  def app_service_units
    [fetch(:puma_service_unit), *Array(fetch(:worker_service_units, []))]
  end

  desc "Restart Puma"
  task :restart_puma do
    on roles(:web) do |_host|
      within release_path do
        execute :sudo, :systemctl, :restart, fetch(:puma_service_unit)
      end
    end
  end

  desc "Restart background worker services"
  task :restart_workers do
    worker_service_units = Array(fetch(:worker_service_units, []))
    next if worker_service_units.empty?

    on roles(:app) do |_host|
      worker_service_units.each do |service_unit|
        execute :sudo, :systemctl, :restart, service_unit
      end
    end
  end

  desc "Show background worker service status"
  task :worker_status do
    worker_service_units = Array(fetch(:worker_service_units, []))
    next if worker_service_units.empty?

    on roles(:app) do |_host|
      worker_service_units.each do |service_unit|
        execute :sudo, :systemctl, :status, service_unit, "--no-pager"
      end
    end
  end

  desc "Show app service status"
  task :status do
    on roles(:app) do |_host|
      app_service_units.each do |service_unit|
        execute :sudo, :systemctl, :status, service_unit, "--no-pager"
      end
    end
  end

  desc "Show recent app service logs"
  task :logs do
    lines = ENV.fetch("LINES", 200)

    on roles(:app) do |_host|
      app_service_units.each do |service_unit|
        execute :sudo, :journalctl, "-u", service_unit, "-n", lines, "--no-pager", "-o", "short-iso"
      end
    end
  end

  desc "Tail app service logs"
  task :tail_logs do
    lines = ENV.fetch("LINES", 100)
    units = app_service_units.flat_map { |service_unit| ["-u", service_unit] }

    on roles(:app) do |_host|
      execute :sudo, :journalctl, *units, "-n", lines, "-f", "-o", "short-iso"
    end
  end

  desc "Tail Puma logs"
  task :tail_puma_logs do
    lines = ENV.fetch("LINES", 100)

    on roles(:web) do |_host|
      execute :sudo, :journalctl, "-u", fetch(:puma_service_unit), "-n", lines, "-f", "-o", "short-iso"
    end
  end

  desc "Tail worker service logs"
  task :tail_worker_logs do
    lines = ENV.fetch("LINES", 100)
    worker_service_units = Array(fetch(:worker_service_units, []))
    next if worker_service_units.empty?

    units = worker_service_units.flat_map { |service_unit| ["-u", service_unit] }

    on roles(:app) do |_host|
      execute :sudo, :journalctl, *units, "-n", lines, "-f", "-o", "short-iso"
    end
  end

  desc "Restart app services"
  task :restart do
    invoke "app:restart_puma"
    invoke "app:restart_workers"
  end
end

after "deploy:published", "app:restart"
