# -*- encoding: utf-8 -*-
require File.expand_path('../lib/graylog2-rails/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "graylog2-rails"
  s.version     = Graylog2Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tuomas Silen"]
  s.email       = ["tuomas@flowdock.com"]
  s.homepage    = "https://github.com/flowdock/graylog2-rails"
  s.summary     = "Push Rails logs also to Graylog2"
  s.description = s.summary

  s.add_dependency 'gelf', '~> 1.4.0'
  s.add_dependency 'activesupport', '~> 4'

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
