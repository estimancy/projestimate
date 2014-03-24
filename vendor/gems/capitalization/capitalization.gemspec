# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capitalization/version'

Gem::Specification.new do |gem|
  gem.name = 'capitalization'
  gem.version = Capitalization::VERSION
  gem.authors = 'Spirula'
  gem.email = 'contact@estimancy.com'
  gem.description = 'As project owner I need to enter organizational and project data (data my organization OR my project expect to capitalize on, independently from the estimation modules).'
  gem.summary = 'Capitalization'
  gem.license = 'AGPL-3'
  gem.homepage = 'httpforge.estimancy.comorg/'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = 'lib'

  #Gem  dependencies: after install, the gem will create migration and run them
  gem.add_development_dependency 'rake'

end
