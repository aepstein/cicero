require 'test_helper'

class RollsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rolls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create roll" do
    assert_difference('Roll.count') do
      post :create, :roll => { }
    end

    assert_redirected_to roll_path(assigns(:roll))
  end

  test "should show roll" do
    get :show, :id => rolls(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => rolls(:one).id
    assert_response :success
  end

  test "should update roll" do
    put :update, :id => rolls(:one).id, :roll => { }
    assert_redirected_to roll_path(assigns(:roll))
  end

  test "should destroy roll" do
    assert_difference('Roll.count', -1) do
      delete :destroy, :id => rolls(:one).id
    end

    assert_redirected_to rolls_path
  end
end
