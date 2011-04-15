require 'bundler'
Bundler::GemHelper.install_tasks

task :default do
  Rake::Task['run_tests'].invoke
end

task :run_tests do 
  require 'test/lispy_test'
end
