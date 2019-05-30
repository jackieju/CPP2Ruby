require 'test_helper'

class TttsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ttt = ttts(:one)
  end

  test "should get index" do
    get ttts_url
    assert_response :success
  end

  test "should get new" do
    get new_ttt_url
    assert_response :success
  end

  test "should create ttt" do
    assert_difference('Ttt.count') do
      post ttts_url, params: { ttt: { name: @ttt.name } }
    end

    assert_redirected_to ttt_url(Ttt.last)
  end

  test "should show ttt" do
    get ttt_url(@ttt)
    assert_response :success
  end

  test "should get edit" do
    get edit_ttt_url(@ttt)
    assert_response :success
  end

  test "should update ttt" do
    patch ttt_url(@ttt), params: { ttt: { name: @ttt.name } }
    assert_redirected_to ttt_url(@ttt)
  end

  test "should destroy ttt" do
    assert_difference('Ttt.count', -1) do
      delete ttt_url(@ttt)
    end

    assert_redirected_to ttts_url
  end
end
