require 'test_helper'

class HoverTest < ActionController::IntegrationTest

  test "should hover on element by test" do
    visit hovers_path
    #sleep(1000)
    hover "Hover"
    assert_contain("block")
  end
end
