$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cocomo_advanced/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cocomo_advanced"
  s.version     = CocomoAdvanced::VERSION
  s.authors     = ["Estimancy"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "http://www.estimancy.com"
  s.summary     = "Summary of CocomoAdvanced."
  s.description = "Description of CocomoAdvanced."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
