task default: :npm_test

desc 'Run `npm test` and exit if it fails.'
task :npm_test do
  abort('npm test failed!') unless system('npm test')
end
