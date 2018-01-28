# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "bakecycle"
set :repo_url, "git@github.com:wizarddevelopment/bakecycle.git"

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'

set :format, :pretty
# set :log_level, :debug
set :pty, true

set :linked_files, %w[config/database.yml config/.envrc]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/images public/system public/pdfs node_modules]
set :bundle_binstubs, nil
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5
