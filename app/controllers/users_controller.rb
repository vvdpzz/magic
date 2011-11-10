class UsersController < ApplicationController
  can_edit_on_the_spot
  def show
    @user = User.find params[:id]
  end
  
  def follow_question
    question = Question.find_by_id params[:qid]
    if question && current_user.follow_question!(question)
      render nothing: true
    else
      render :json => {status: :unprocessable_entity}
    end
  end
  
  def unfollow_question
    question = Question.find_by_id params[:qid]
    if question && current_user.unfollow_question!(question)
      render nothing: true
    else
      render :json => {status: :unprocessable_entity}
    end
  end
  
  def follow_user
    user = User.find_by_id params[:uid]
    if user && current_user.follow_user!(user)
      render nothing: true
    else
      render :json => {status: :unprocessable_entity}
    end
  end
  
  def unfollow_user
    user = User.find_by_id params[:uid]
    if user && current_user.unfollow_user!(user)
      render nothing: true
    else
      render :json => {status: :unprocessable_entity}
    end
  end
  
end
