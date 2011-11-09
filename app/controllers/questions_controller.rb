class QuestionsController < ApplicationController
  before_filter :vote_init, :only => [:vote_for, :vote_against]
  
  def index
    @questions = Question.all
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build params[:question]
    if @question.save and @question.deduct_credit and @question.order_credit and @question.deduct_reputation and @question.order_reputation
      redirect_to @question
    else
      render :new
    end
  end
  
  def show
    @question = Question.find params[:id]
  end

  def destroy
  end
  
  def vote_for
    if current_user.reputation >= Settings.vote_for_limit and @voted != true
      if @voted == nil
        if current_user.vote_for @question
          render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
        end
      else
        if current_user.vote_exclusively_against @question
          render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
        end
      end
    end
  end
  
  def vote_against
    if current_user.reputation >= Settings.vote_against_limit and @voted != false
      if @voted == nil
        if current_user.vote_against @question
          render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
        end
      else
        if current_user.vote_exclusively_for @question
          render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
        end
      end
    end
  end
  
  protected
    def vote_init
      @question = Question.select("id").find_by_id(params[:id])
      @voted = @question.trivalent_voted_by? current_user
    end
end
