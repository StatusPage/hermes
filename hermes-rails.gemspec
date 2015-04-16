$:.push File.expand_path("../lib", __FILE__)

require "hermes/version"

Gem::Specification.new do |s|
  s.name        = "hermes-rails"
  s.version     = Hermes::VERSION
  s.authors     = ["Scott Klein", "Tyler Davis"]
  s.email       = ["scott@statuspage.io", "tyler@statuspage.io"]
  s.homepage    = "https://github.com/StatusPage/hermes"
  s.summary     = "Rails Action Mailer adapter for balancing multiple providers across email, SMS, and webhook"
  s.description = "Rails Action Mailer adapter for balancing multiple providers across email, SMS, and webhook"
  s.license = 'MIT'

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0.0"
  s.add_dependency "httparty", ">= 0.12"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "ffaker"
  s.add_development_dependency "minitest-spec-rails"
  s.add_development_dependency "appraisal"
  s.add_development_dependency "webmock"
  s.add_development_dependency "byebug"
  s.add_development_dependency "mocha"
end
