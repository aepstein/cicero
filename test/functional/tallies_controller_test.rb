require 'test_helper'

class TalliesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tallies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tally
    assert_difference('Tally.count') do
      post :create, :tally => { }
    end

    assert_redirected_to tally_path(assigns(:tally))
  end

  def test_should_show_tally
    get :show, :id => tallies(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => tallies(:one).id
    assert_response :success
  end

  def test_should_update_tally
    put :update, :id => tallies(:one).id, :tally => { }
    assert_redirected_to tally_path(assigns(:tally))
  end

  def test_should_destroy_tally
    assert_difference('Tally.count', -1) do
      delete :destroy, :id => tallies(:one).id
    end

    assert_redirected_to tallies_path
  end
end
