require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get sync" do
    get orders_sync_url
    assert_response :success
  end
end
