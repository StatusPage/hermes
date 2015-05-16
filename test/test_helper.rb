# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "minitest/autorun"
require "database_cleaner"
require "ffaker"
require "factory_girl_rails"
require "webmock/minitest"
require "byebug"
require "mocha/setup"

# includes for testing
require "mailgun"
require "twitter"

Rails.backtrace_cleaner.remove_silencers!

#include factories
Dir["#{File.dirname(__FILE__)}/dummy/test/factories/*.rb"].each { |f| require f }
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
# if ActiveSupport::TestCase.method_defined?(:fixture_path=)
#   ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
#   ActiveSupport::TestCase.fixtures :all
# end

ActiveRecord::Migrator.migrate File.expand_path('../dummy/db/migrate/', __FILE__)

class Minitest::Spec
  include FactoryGirl::Syntax::Methods

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end

  def reset_email!
    ActionMailer::Base.deliveries.delete_if{|message| message.hermes_type == :email}
  end

  def last_email
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :email}.last
  end

  def email_count
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :email}.count
  end

  def reset_texts!
    ActionMailer::Base.deliveries.delete_if{|message| message.hermes_type == :sms}
  end

  def last_text
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :sms}.last
  end

  def texts_count
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :sms}.count
  end

  def reset_tweets!
    ActionMailer::Base.deliveries.delete_if{|message| message.hermes_type == :tweet}
  end

  def last_tweet
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :tweet}.last
  end

  def tweets_count
    ActionMailer::Base.deliveries.select{|message| message.hermes_type == :tweet}.count
  end
end

class ActionController::TestCase
  include FactoryGirl::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  include FactoryGirl::Syntax::Methods

  def setup
    stub_request(:any, /.*/).
    to_return(
        :status   => 200,
        :body     => "{}"
    )

  end

end