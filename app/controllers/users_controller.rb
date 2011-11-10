class UsersController < ApplicationController
  can_edit_on_the_spot
  def show
    @user = User.find params[:id]
  end
  
  def follow
    user = User.find params[:id]
    flag = true
    if user and user.id != current_user.id
     records = FollowedUser.where(:user_id => user.id, :follower_id => current_user.id)
     if records.empty?
       user.followers.create(:follower_id => current_user.id)
     else
       record = records.first
       flag = record.flag if record.update_attribute(:flag, !record.flag)
     end
     render :json => {:flag => flag}, :status => :ok
    else
     render :json => {:error => true}, :status => :unprocessable_entity
    end
  end
end
