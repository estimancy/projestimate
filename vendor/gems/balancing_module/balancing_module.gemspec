$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "balancing_module/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "balancing_module"
  s.version     = BalancingModule::VERSION
  s.authors     = ["Estimancy"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "http://forge.estimancy.com"
  s.summary     = "Summary of BalancingModule."
  s.description = "Balancing Module includes the Effort-Balancing, Size-Balancing, Cost-Balancing,... modules."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
