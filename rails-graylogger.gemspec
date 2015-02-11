# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails-graylogger/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "rails-graylogger"
  s.version     = RailsGraylogger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tuomas Silen"]
  s.email       = ["tuomas@flowdock.com"]
  s.homepage    = "https://github.com/flowdock/rails-graylogger"
  s.summary     = "Push Rails logs also to Graylog2"
  s.description = s.summary

  s.add_dependency 'gelf', '~> 1.4.0'
  s.add_dependency 'activesupport', '~> 4'
  s.add_dependency 'request_store', '~> 1.0'

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
