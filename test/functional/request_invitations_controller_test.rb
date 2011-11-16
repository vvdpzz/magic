require 'test_helper'

class RequestInvitationsControllerTest < ActionController::TestCase
  setup do
    @request_invitation = request_invitations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:request_invitations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create request_invitation" do
    assert_difference('RequestInvitation.count') do
      post :create, request_invitation: @request_invitation.attributes
    end

    assert_redirected_to request_invitation_path(assigns(:request_invitation))
  end

  test "should show request_invitation" do
    get :show, id: @request_invitation.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @request_invitation.to_param
    assert_response :success
  end

  test "should update request_invitation" do
    put :update, id: @request_invitation.to_param, request_invitation: @request_invitation.attributes
    assert_redirected_to request_invitation_path(assigns(:request_invitation))
  end

  test "should destroy request_invitation" do
    assert_difference('RequestInvitation.count', -1) do
      delete :destroy, id: @request_invitation.to_param
    end

    assert_redirected_to request_invitations_path
  end
end
