require 'action_mailer'
require 'json'


Dir[File.dirname(__FILE__) + '/angelia/*.rb'].each {|file| require file }

module Angelia
end
