# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "bakecycle"
set :repo_url, "git@github.com:reconbot/bakecycle.git"
set :ssh_options, forward_agent: true

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'

set :format, :pretty
# set :log_level, :debug
set :pty, true

set :linked_files, %w[config/database.yml]
set :linked_dirs, %w[
  log tmp/pids tmp/cache
  tmp/sockets vendor/bundle
  public/images public/system
  public/pdfs node_modules
]
set :bundle_binstubs, nil
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :app do
  desc "Restart Puma and Solid Queue"
  task :restart do
    on roles(:web) do |_host|
      within release_path do
        execute :sudo, :systemctl, :restart, "puma.service"
        execute :sudo, :systemctl, :restart, "solid_queue.service"
      end
    end
  end
end

after "deploy:restart", "app:restart"
