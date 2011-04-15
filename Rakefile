require 'bundler'
Bundler::GemHelper.install_tasks

task :default do
  Rake::Task['run_tests'].invoke
end

task :run_tests do 
  if RUBY_VERSION =~ /^1.9/
    require_relative 'test/lispy_test' # for fuck's sake.
  else
    require 'test/lispy_test'
  end
end
