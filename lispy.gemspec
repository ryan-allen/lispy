# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lispy"

Gem::Specification.new do |s|
  s.name        = "lispy"
  s.version     = Lispy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ryan Allen"]
  s.email       = ["ryan@ryanface.com"]
  s.homepage    = "http://rubygems.org/gems/lispy"
  s.summary     = %q{Code as data in Ruby, without the metaprogramming madness.}
  s.description = %q{Create data structures in Ruby using idomatic 'DSL' constructs. Free yourself of metaprogramming madness, write nice APIs and decouple the implementation from it!}

  s.rubyforge_project = "lispy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
