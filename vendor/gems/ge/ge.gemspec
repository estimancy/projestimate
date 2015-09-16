$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ge/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ge"
  s.version     = Ge::VERSION
  s.authors     = ["Projestimate"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "http://forge.estimancy.com"
  s.summary     = "Summary of Ge."
  s.description = "Description of Ge."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
