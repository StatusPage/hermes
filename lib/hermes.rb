require 'action_mailer'
require 'json'

# all of the Hermes support files
Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/hermes/*.rb'].each {|file| require file }

# all of the generic (abstract) provider support files
Dir[File.dirname(__FILE__) + '/providers/*.rb'].each {|file| require file }

# all of the actual provider support files
Dir[File.dirname(__FILE__) + '/providers/**/*.rb'].each {|file| require file }

module Hermes
end
