# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pooka/version'

Gem::Specification.new do |spec|
  spec.name          = 'pooka'
  spec.version       = Pooka::VERSION
  spec.authors       = ['sugamasao']
  spec.email         = ['sugamasao@gmail.com']
  spec.summary       = 'Simply Daemon Tool'
  spec.description   = 'Simply Daemon Tool Your Program to Daemonize'
  spec.homepage      = 'https://github.com/sugamasao/pooka'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry'
#  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rubocop'
end
