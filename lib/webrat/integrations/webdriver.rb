require "webrat/webdriver"

if defined?(ActionController::IntegrationTest)
  module ActionController #:nodoc:
    IntegrationTest.class_eval do
      include Webrat::Methods
      include Webrat::Webdriver::Methods
      include Webrat::Webdriver::Matchers
    end
  end
end
