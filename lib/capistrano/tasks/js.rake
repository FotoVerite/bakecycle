namespace :js do
  desc 'Build production JS bundle with esbuild'
  task :build do
    on roles(:web) do
      within release_path do
        execute :npm, 'run build:prod'
      end
    end
  end
end

# Run after npm install, before asset precompile
after 'npm:install', 'js:build'
