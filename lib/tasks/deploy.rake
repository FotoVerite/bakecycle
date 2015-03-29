require 'heroku_platform_client'

desc 'Deploy script usage information'
task :deploy do
  puts 'Deploys the currently checked out revision to heroku.'
  puts 'Migrates and restarts the app after the deploy.'
  puts 'Tags the release and pushes it to github.'
  puts 'Uses the ~/.netrc file for authentication per the heroku toolbelt.'
  puts "\nusage: rake deploy:{staging|production}"
  exit 0
end

namespace :deploy do
  opt = {
    app: nil,
    github_repo: 'git@github.com:wizarddevelopment/bakecycle.git'
  }

  desc 'Deploy to Production'
  task production: [:set_production, :push_heroku, :migrate, :restart, :tag]

  desc 'Deploy to Staging'
  task staging: [:set_staging, :force_push_heroku, :migrate, :restart]

  task :set_production do
    opt[:env] = 'prod'
    opt[:app] = 'bakecycle-production'
  end

  task :set_staging do
    opt[:env] = 'staging'
    opt[:app] = 'bakecycle-staging'
  end

  task :push_heroku do
    branch = 'HEAD'
    puts "Pushing #{branch} to Heroku ..."
    execute "git push git@heroku.com:#{opt[:app]}.git #{branch}:master"
  end

  task :force_push_heroku do
    branch = 'HEAD'
    puts "Force pushing #{branch} to Heroku ..."
    execute "git push -f git@heroku.com:#{opt[:app]}.git #{branch}:master"
  end

  task :tag do
    heroku = HerokuPlatformClient.local_auth(opt[:app])
    version = heroku.latest_release['version']
    release_name = "#{opt[:env]}/v#{version}"
    puts "Tagging release #{release_name}"
    execute "git tag -a #{release_name} -m 'Tagged release'"
    execute "git push #{opt[:github_repo]} #{release_name}"
  end

  task :migrate do
    puts "Migrating #{opt[:app]}"
    execute_remote(opt[:app], 'rake db:migrate')
  end

  task :restart do
    puts "Restarting #{opt[:app]}"
    heroku = HerokuPlatformClient.local_auth(opt[:app])
    heroku.restart_all
  end
end

def execute_remote(app, cmd)
  print "Executing '#{cmd}' on #{app}\n"
  heroku = HerokuPlatformClient.local_auth(app)
  output, code = heroku.run_with_code(cmd)
  puts output.gsub(/^/, "#\t")
  return true if code == 0
  puts "Failed to Execute #{cmd} with code #{code}"
  exit(1)
end

def execute(cmd)
  print "Executing '#{cmd}'\n"
  success = system(cmd)
  return true if success
  code = $CHILD_STATUS.to_i
  puts "Failed to Execute #{cmd} with code #{code}"
  exit(1)
end
