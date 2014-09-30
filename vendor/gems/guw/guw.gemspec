$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "guw/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "guw"
  s.version     = Guw::VERSION
  s.authors     = ["Projestimate"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "forge.estimancy.com"
  s.summary     = "Summary of GUW."
  s.description = "Description of GUW."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
