$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "expert_judgement/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "expert_judgement"
  s.version     = ExpertJudgement::VERSION
  s.authors     = ["Projestimate"]
  s.email       = ["contact@estimancy.com"]
  s.homepage    = "forge.estimancy.com"
  s.summary     = "Summary of ExpertJudgement."
  s.description = "Description of ExpertJudgement."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
