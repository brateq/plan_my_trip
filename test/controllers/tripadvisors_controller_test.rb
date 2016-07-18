require 'test_helper'

class TripadvisorsControllerTest < ActionController::TestCase
  setup do
    @tripadvisor = tripadvisors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tripadvisors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tripadvisor" do
    assert_difference('Tripadvisor.count') do
      post :create, tripadvisor: {  }
    end

    assert_redirected_to tripadvisor_path(assigns(:tripadvisor))
  end

  test "should show tripadvisor" do
    get :show, id: @tripadvisor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tripadvisor
    assert_response :success
  end

  test "should update tripadvisor" do
    patch :update, id: @tripadvisor, tripadvisor: {  }
    assert_redirected_to tripadvisor_path(assigns(:tripadvisor))
  end

  test "should destroy tripadvisor" do
    assert_difference('Tripadvisor.count', -1) do
      delete :destroy, id: @tripadvisor
    end

    assert_redirected_to tripadvisors_path
  end
end
