# frozen_string_literal: true

# jsbundling-rails hangs `javascript:install` -- a bare, unpinned `yarn install` -- off
# `javascript:build`, which `assets:precompile` depends on. That is a second package
# manager doing a second install: capistrano-npm has already run
# `npm install --production` against this release before `deploy:updated`, so the modules
# the build needs are present (esbuild is a regular dependency, not a devDependency)
# before precompile starts.
#
# The redundant install is also the one that breaks deploys. Being neither frozen nor
# --production, it re-resolves devDependencies, and on production's Node 18.19.1 jest's
# tree resolves glob@10.5.0 -> lru-cache@11.5.2, which declares `engines.node: 20 || >=22`
# and aborts the whole precompile:
#
#   error lru-cache@11.5.2: The engine "node" is incompatible with this module.
#   error Found incompatible module.
#   Tasks: TOP => assets:precompile => javascript:build => javascript:install
#
# Clearing only the actions keeps the task itself defined, so anything that depends on it
# still resolves -- it just stops shelling out. `javascript:build` (npm run build) is
# untouched and still produces the bundle.
Rake::Task["javascript:install"].clear_actions if Rake::Task.task_defined?("javascript:install")
