# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocomo_basic/version'

Gem::Specification.new do |gem|
  gem.name = 'cocomo_basic'
  gem.version = CocomoBasic::VERSION
  gem.authors = 'Spirula'
  gem.email = 'contact@estimancy.com'
  gem.summary = 'Implementation of Cocomo Basis (aka Cocomo 81-classic) estimation method for ProjEstimate'
  gem.description = 'Basic COCOMO (Constructive Cost Model) computes software development effort (and cost) as a function of program size. Program size is expressed in estimated thousands of source lines of code (SLOC)'
  gem.license = 'AGPL-3'
  gem.homepage = 'http://www.estimancy.com'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = 'lib'
end
