require 'test_helper'

class PetitionersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:petitioners)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_petitioner
    assert_difference('Petitioner.count') do
      post :create, :petitioner => { }
    end

    assert_redirected_to petitioner_path(assigns(:petitioner))
  end

  def test_should_show_petitioner
    get :show, :id => petitioners(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => petitioners(:one).id
    assert_response :success
  end

  def test_should_update_petitioner
    put :update, :id => petitioners(:one).id, :petitioner => { }
    assert_redirected_to petitioner_path(assigns(:petitioner))
  end

  def test_should_destroy_petitioner
    assert_difference('Petitioner.count', -1) do
      delete :destroy, :id => petitioners(:one).id
    end

    assert_redirected_to petitioners_path
  end
end
