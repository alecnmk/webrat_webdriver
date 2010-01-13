require "webrat"
require "webrat/selenium/silence_stream"
require "webrat/webdriver/webdriver_session"
require "webrat/core/matchers"
require "webrat/core_extensions/tcp_socket"

module Webrat
  module Webdriver
    module Methods
      def response
        webrat_session.response
      end

      def save_and_open_screengrab
        webrat_session.save_and_open_screengrab
      end
    end
  end
end
