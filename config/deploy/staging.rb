set :deploy_to, "/var/www/bakecycle_staging"
set :user, "deploy"
set :branch, "costing2"
set :ssh_options, forward_agent: true, port: 21500
set :workers, "*" => 2
set :resque_environment_task, true

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w[deploy@172.104.22.62]
role :web, %w[deploy@172.104.22.62]
role :db,  %w[deploy@172.104.22.62]
