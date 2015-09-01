$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "staffing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "staffing"
  s.version     = Staffing::VERSION
  s.authors     = ["Estimancy"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "forge.estimancy.com"
  s.summary     = "Summary of Staffing Module."
  s.description = "Description of Staffing Module."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.21"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end

