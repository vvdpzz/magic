class UsersController < ApplicationController
  can_edit_on_the_spot
  
  def show
    @user = User.find params[:id]
  end
end
