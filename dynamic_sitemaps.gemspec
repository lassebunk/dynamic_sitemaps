# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

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
  gem.add_development_dependency "nokogiri", "~> 1.6.0"
  gem.add_development_dependency "timecop", "~> 0.6.1"
  gem.add_development_dependency "webmock", "~> 1.13.0"
end