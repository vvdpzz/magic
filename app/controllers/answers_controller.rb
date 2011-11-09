class AnswersController < ApplicationController
  before_filter :vote_init, :only => [:vote_for, :vote_against]
  
  def create
    question = Question.find params[:answer][:question_id]
    if question.could_answer_by? current_user.id
      @answer = current_user.answers.build(params[:answer])
      if @answer.save and question.correct_answer_id == 0 and @answer.deduct_reputation and @answer.order_reputation
        redirect_to question
      end
    end
  end
  
  def vote_for
    if current_user.reputation >= Settings.vote_for_limit and @voted != true
      if @voted == nil
        if current_user.vote_for @answer
          render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
        end
      else
        if current_user.vote_exclusively_against @answer
          render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
        end
      end
    end
  end
  
  def vote_against
    if current_user.reputation >= Settings.vote_against_limit and @voted != false
      if @voted == nil
        if current_user.vote_against @answer
          render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
        end
      else
        if current_user.vote_exclusively_for @answer
          render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
        end
      end
    end
  end
  
  protected
    def vote_init
      @answer = Answer.select("id").find_by_id(params[:id])
      @voted = @answer.trivalent_voted_by? current_user
    end
end
