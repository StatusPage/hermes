$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mailgun/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "angelia"
  s.version     = Angelia::VERSION
  s.authors     = ["Scott Klein", "Tyler Davis"]
  s.email       = ["scott@statuspage.io", "tyler@statuspage.io"]
  s.homepage    = "https://github.com/StatusPage/angelia/"
  s.summary     = "Rails Action Mailer adapter for balancing multiple providers across email, SMS, and webhook"
  s.description = "Rails Action Mailer adapter for balancing multiple providers across email, SMS, and webhook"
  s.license = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_dependency "rest-client", "~> 1.6.7"

  s.add_development_dependency "sqlite3"
end
