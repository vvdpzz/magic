class UsersController < ApplicationController
  can_edit_on_the_spot
  def show
    @user = User.find params[:id]
  end
  
  def cash
    render :json => {credit: current_user.credit, reputation: current_user.reputation}, status: :ok 
  end
  
  def follow
    user = User.find params[:id]
    flag = true
    if user and user.id != current_user.id
     records = FollowedUser.where(:user_id => user.id, :follower_id => current_user.id)
     if records.empty?
       user.followers.create(:follower_id => current_user.id)
       $redis.sadd("users:#{current_user.id}.following_users", params[:id])
       $redis.sadd("users:#{params[:id]}.follower_users", current_user.id)
     else
       record = records.first
       if record.flag
         $redis.srem("users:#{current_user.id}.following_users", params[:id])
         $redis.srem("users:#{params[:id]}.follower_users", current_user.id)
       else
         $redis.sadd("users:#{current_user.id}.following_users", params[:id])
         $redis.sadd("users:#{params[:id]}.follower_users", current_user.id)
       end
       flag = record.flag if record.update_attribute(:flag, !record.flag)
     end
     render :json => {:flag => flag}, status: :ok
    else
     render :json => {:error => true}, :status => :unprocessable_entity
    end
  end
  
  def myquestions
    user = User.find params[:id]
    @questions = user.questions
    render partial: "myquestion", :collection => @questions, layout: false
  end
  
  def myanswers
    user = User.find params[:id]
    @answers = user.answers
    render partial: "myanswer", :collection => @answers, layout: false
  end
  
  def winquestions
    user = User.find params[:id]
    @questions = user.questions
    render partial: "myquestion", :collection => @questions, layout: false
  end
  
  def favourites
    
  end
  
  def watchs
    
  end
  
  def followings
    
  end
  
  def followers
    
  end
end
