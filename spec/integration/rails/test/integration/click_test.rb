
require 'test_helper'

class ClickTest < ActionController::IntegrationTest

  test "should click on elements with text in @alt" do
    visit clicks_path
    click "Image"
    assert_contain "success"
  end


  test "should click on elements with text as inner html" do
    visit clicks_path
    click "Block"
    assert_contain "success"
  end
end
