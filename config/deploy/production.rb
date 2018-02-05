set :deploy_to, "/var/www/bakecycle_production"
set :user, "deploy"
set :branch, "rails5"
set :ssh_options, forward_agent: true, port: 21500
set :workers, "*" => 2
set :resque_environment_task, true
set :puma_conf, "#{current_path}/config/puma.rb"
set :puma_state, "#{shared_path}/pids/puma.state"
set :puma_pid, "#{shared_path}/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/sockets/puma.sock"    #accept array for multi-bind

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w[deploy@172.104.31.237]
role :web, %w[deploy@172.104.31.237]
role :db,  %w[deploy@172.104.31.237]
role :resque_worker, %w[deploy@172.104.31.237]
role :resque_scheduler, %w[deploy@172.104.31.237]
