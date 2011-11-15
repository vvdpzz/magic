# encoding: utf-8
class UsersController < ApplicationController
  can_edit_on_the_spot
  before_filter :build_user, :except => [:cash, :update_attribute_on_the_spot]
  def show
  end
  
  def cash
    render :json => {credit: current_user.credit, reputation: current_user.reputation}, status: :ok 
  end
  
  def follow
    flag = true
    if @user and @user.id != current_user.id
      records = FollowedUser.where(:user_id => @user.id, :follower_id => current_user.id)
      if records.empty?
        @user.followers.create(:follower_id => current_user.id)
        $redis.sadd("users:#{current_user.id}.following_users", params[:id])
        $redis.sadd("users:#{params[:id]}.follower_users", current_user.id)
        
        # add notification to db and pusher
        html = "<a href='/users/#{current_user.id}'>#{current_user.name}</a> 关注了你。"
        Notification.create(:user_id => @user.id, :content => html)
        Pusher["presence-notifications_#{@user.id}"].trigger('notification_created', html)
      else
        record = records.first
        if record.flag
          $redis.srem("users:#{current_user.id}.following_users", params[:id])
          $redis.srem("users:#{params[:id]}.follower_users", current_user.id)
        else
          $redis.sadd("users:#{current_user.id}.following_users", params[:id])
          $redis.sadd("users:#{params[:id]}.follower_users", current_user.id)
          
          # add notification to db and pusher
          html = "<a href='/users/#{current_user.id}'>#{current_user.name}</a> 关注了你。"
          Notification.create(:user_id => @user.id, :content => html)
          Pusher["presence-notifications_#{@user.id}"].trigger('notification_created', html)
        end
        flag = record.flag if record.update_attribute(:flag, !record.flag)
      end
      render :json => {:flag => flag}, status: :ok
    else
      render :json => {:error => true}, :status => :unprocessable_entity
    end
  end
  
  def myquestions
    @questions = @user.questions
    render partial: "myquestion", :collection => @questions, :as => :question,  layout: false
  end
  
  def myanswers
    @answers = @user.answers
    render partial: "myanswer", :collection => @answers, :as => :answer, layout: false
  end
  
  def winquestions
    @questions = (@user.credit_winners + @user.reputation_winners).uniq.collect{|item| item.question}
    render partial: "winquestions", :collection => @questions, :as => :question, layout: false
  end
  
  def favorites
    @questions = Question.find_by_sql("select * from questions where id in (select question_id from favorite_questions where user_id = #{@user.id} and status = true)")
    render partial: "favorites", :collection => @questions, :as => :question, layout: false
  end
  
  def watches
    @questions = Question.find_by_sql("select * from questions where id in (select question_id from followed_questions where user_id = #{@user.id} and status = true)")
    render partial: "watches", :collection => @questions, :as => :question, layout: false
  end
  
  def followings
    @users = @user.followings_inredis
    render partial: "follow", :collection => @users, :as => :user, layout: false
  end
  
  def followers
    @users = @user.followers_inredis
    render partial: "follow", :collection => @users, :as => :user, layout: false
  end
  
  protected
    def build_user
      @user = User.find params[:id]
    end
end
