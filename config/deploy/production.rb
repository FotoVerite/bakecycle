set :deploy_to, "/var/www/bakecycle_production"
set :user, "deploy"
set :branch, "master"
set :ssh_options, forward_agent: true, port: 21500

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w[deploy@97.107.141.39]
role :web, %w[deploy@97.107.141.39]
role :db, %w[deploy@97.107.141.39]
