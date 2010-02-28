require "webrat/core/save_and_open_page"
require "webrat/selenium/application_server_factory"
require "webrat/selenium/application_servers/base"
require "selenium-webdriver"

module Webrat

  class WebdriverResponse
    attr_reader :body
    attr_reader :session

    def initialize(session, body)
      @session = session
      @body = body
    end

    def webdriver
      session.webdriver
    end
  end

  class WebdriverSession
    include Webrat::SaveAndOpenPage
    #include Webrat::Selenium::SilenceStream

    def initialize(*args) # :nodoc:
    end

    def simulate
    end

    def automate
      yield
    end

    def visit(url)
      webdriver.navigate.to("http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port}" + url)
    end

    webrat_deprecate :visits, :visit

    def fill_in(field_identifier, options)
      element = find_field(field_identifier)
      element.clear
      element.send_keys("#{options[:with]}")
    end

    webrat_deprecate :fills_in, :fill_in

    def response
      WebdriverResponse.new(self, response_body)
    end

    def response_body #:nodoc:
      webdriver.page_source
    end

    def current_url
      webdriver.current_url
    end

    def click(locator = nil, options = {})
      begin
        webdriver.find_element(:link, locator).click
      rescue ::Selenium::WebDriver::Error::WebDriverError
        begin
          webdriver.find_element(:id, locator).click
        rescue ::Selenium::WebDriver::Error::WebDriverError
          begin
            webdriver.find_element(:xpath, "//*[text()='#{locator}']").click
          rescue ::Selenium::WebDriver::Error::WebDriverError
						begin
							webdriver.find_element(:xpath, locator).click
						rescue ::Selenium::WebDriver::Error::WebDriverError
							click_button(locator, options)
						end
          end
        end
      end
    end #click

    def click_button(locator = nil, options = {})
      #button_locator = ButtonLocator.new(locator)
      if locator.nil? 
        webdriver.find_element(:xpath, "//input|button[@type='submit']").click
      else
        begin
        webdriver.find_element(:xpath, "//button[(@type='image' or @type='submit') and (contains(text(),'#{locator}') or @value='#{locator}' or @id='#{locator}')]").click
        rescue
          webdriver.find_element(:xpath, "//input[(@type='image' or @type='submit') and (contains(text(),'#{locator}') or @value='#{locator}' or @id='#{locator}' or @alt='#{locator}')]").click
        end
      end
    end

    webrat_deprecate :clicks_button, :click_button

    def click_link(link_locator, options = {})
      begin
        webdriver.find_element(:link, link_locator).click
      rescue ::Selenium::WebDriver::Error::WebDriverError
        begin
          webdriver.find_element(:id, link_locator).click
        rescue
					begin
						webdriver.find_element(:xpath, "//a[@title='#{link_locator}']").click
					rescue
						webdriver.find_element(:xpath, "//a//*[text()='#{link_locator}']").click
					end
        end
      end
    end

    webrat_deprecate :clicks_link, :click_link

    def click_link_within(selector, link_text, options = {})
      raise WebratError.new('Not implemented yet')
    end

    webrat_deprecate :clicks_link_within, :click_link_within

    def select(option_text, options = {})
      select_element = options[:from] ?
        find_field(options[:from]) : webdriver
      select_element.find_element(:xpath, "//option[text()='#{option_text}']").select
    end


    webrat_deprecate :selects, :select

    def choose(label_text)
      webdriver.find_element(:xpath, "//label[text()='#{label_text}']").click
    end

    webrat_deprecate :chooses, :choose

    def check(label_text)
      find_field(label_text).click
    end
    alias_method :uncheck, :check

    webrat_deprecate :checks, :check

    def fire_event(field_identifier, event)
      raise WebratError.new('Not implemented yet')
    end

    def key_down(field_identifier, key_code)
      raise WebratError.new('Not implemented yet')
      #webdriver.find_element(:id, field_identifier).send_keys(key_code)
    end

    def key_up(field_identifier, key_code)
      raise WebratError.new('Not implemented yet')
    end

    def webdriver
      return $browser if $browser
      setup
      $browser
    end

    webrat_deprecate :browser, :webdriver

    def save_and_open_screengrab
      return unless File.exist?(saved_page_dir)

      filename = "#{saved_page_dir}/webrat-#{Time.now.to_i}.png"
      $browser.save_screenshot(filename)
      
      open_in_browser(filename)
    end


		def hover(locator)
			webdriver.find_element(:xpath, "//*[contains(text(),'#{locator}')]").hover
		end

    protected
    def setup #:nodoc:
      Webrat::Selenium::ApplicationServerFactory.app_server_instance.boot

      create_browser
    end

    def create_browser
      $browser = ::Selenium::WebDriver.for :firefox
      raise "browser is not created" if $browser.nil?
      
      at_exit do
        $browser.quit
      end
    end

    def find_field(locator)
      # locate by id
      begin
        # locate by id
        webdriver.find_element(:id, locator)
      rescue ::Selenium::WebDriver::Error::WebDriverError
        begin 
          webdriver.find_element(:name, locator)
        rescue
          begin
            #locate by parent label
            webdriver.find_element(:xpath, "//label[contains(text(),'#{locator}')]/input")
          rescue ::Selenium::WebDriver::Error::WebDriverError
            label_for = webdriver.find_element(:xpath, "//label[contains(text(),'#{locator}')]")['for']
            begin
              webdriver.find_element(:id, label_for)
						rescue ::Selenium::WebDriver::Error::WebDriverError
              webdriver.find_element(:name, label_for)
            end
          end
        end
      end
    end #find_element
  end
end
