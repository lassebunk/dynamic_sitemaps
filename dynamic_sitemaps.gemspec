# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamic_sitemaps/version'

Gem::Specification.new do |gem|
  gem.name          = "dynamic_sitemaps"
  gem.version       = DynamicSitemaps::VERSION
  gem.authors       = ["Lasse Bunk"]
  gem.email         = ["lassebunk@gmail.com"]
  gem.description   = %q{Dynamic Sitemaps is a plugin for Ruby on Rails that enables you to easily create flexible, dynamic sitemaps for Google, Bing, and Yahoo.}
  gem.summary       = %q{Dynamic sitemap generation plugin for Ruby on Rails.}
  gem.homepage      = "http://github.com/lassebunk/dynamic_sitemaps"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rails", "~> 3.2.13"
  gem.add_development_dependency "sqlite3"
end