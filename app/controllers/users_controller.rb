class UsersController < ApplicationController
  can_edit_on_the_spot
  
  def show
    @user = User.find params[:id]
  end
  
  def cash
    render :json => {credit: current_user.credit, reputation: current_user.reputation}, status: :ok 
  end
end
