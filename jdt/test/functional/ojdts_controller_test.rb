require 'test_helper'

class OjdtsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ojdts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ojdt" do
    assert_difference('Ojdt.count') do
      post :create, :ojdt => { }
    end

    assert_redirected_to ojdt_path(assigns(:ojdt))
  end

  test "should show ojdt" do
    get :show, :id => ojdts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ojdts(:one).to_param
    assert_response :success
  end

  test "should update ojdt" do
    put :update, :id => ojdts(:one).to_param, :ojdt => { }
    assert_redirected_to ojdt_path(assigns(:ojdt))
  end

  test "should destroy ojdt" do
    assert_difference('Ojdt.count', -1) do
      delete :destroy, :id => ojdts(:one).to_param
    end

    assert_redirected_to ojdts_path
  end
end
