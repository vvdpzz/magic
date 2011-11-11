class AnswersController < ApplicationController
  before_filter :vote_init, :only => [:vote_for, :vote_against]
  
  def create
    question = Question.find params[:answer][:question_id]
    if not question.could_answer_by?(current_user.id)
      render json: {:errors => "You've already answered this question"}, :status => :unprocessable_entity
      return
    end
    if question.not_free? and question.correct_answer_id == 0 and current_user.reputation < Settings.answer_price
      render json: {:errors => "You do not have enough reputation to answering a paid question, 5 reputation is minimum."}, :status => :unprocessable_entity
      return
    end
    @answer = current_user.answers.build(params[:answer])
    if @answer.save
      question.not_free? and question.correct_answer_id == 0 and @answer.deduct_reputation and @answer.order_reputation
      render json: {answers_count: question.answers_count+1, html: render_to_string(partial: 'answer', locals: {answer: @answer}), status: :ok}
    else
      render json: {:errors => "Oops! Some errors happened."}
    end
  end
  
  def vote_for
    if current_user.reputation < Settings.vote_for_limit
      render json: {errors: "Reputation not enough", rc: 1}, status: :unprocessable_entity
      return
    end
    if @voted
      render json: {errors: "Already vote for", rc: 2}, status: :unprocessable_entity
      return
    end
    if @voted == nil
      if current_user.vote_for @answer
        @answer.update_attribute(:votes_count, @answer.plusminus)
        render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
      end
    else
      if current_user.vote_exclusively_for @answer
        @answer.update_attribute(:votes_count, @answer.plusminus)
        render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
      end
    end
  end

  def vote_against
    if current_user.reputation < Settings.vote_against_limit
      render json: {errors: "Reputation not enough", rc: 3}, status: :unprocessable_entity
      return
    end
    if @voted == false
      render json: {errors: "Already vote against", rc: 2}, status: :unprocessable_entity
      return
    end
    if @voted == nil
      if current_user.vote_against @answer
        @answer.update_attribute(:votes_count, @answer.plusminus)
        render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
      end
    else
      if current_user.vote_exclusively_against @answer
        @answer.update_attribute(:votes_count, @answer.plusminus)
        render json: {:id => @answer.id, :votes_count => @answer.plusminus}, status: :ok
      end
    end
  end
  
  def accept
    question = Question.find params[:question_id]
    answer = question.answers.find params[:id]
    if question and answer and current_user.id == question.user_id and question.correct_answer_id == 0
      question.update_attribute(:correct_answer_id, answer.id)
      answer.update_attribute(:is_correct, true)
      if question.not_free?
        if question.reputation > 0
          answer.user.update_attribute(:reputation, answer.user.reputation + question.reputation)
          order = ReputationTransaction.new(
            :user_id => answer.user.id,
            :question_id => question.id,
            :answer_id => answer.id,
            :value => question.credit,
            :payment => false,
            :trade_type => TradeType::ACCEPT,
            :trade_status => TradeStatus::SUCCESS
          )
          order.save
          
          # change question user's order status from normal to success
          orders = current_user.reputation_transactions.where(:question_id => question.id, :trade_type => TradeType::ASK)
          orders.each do |order|
            order.update_attributes(
              :trade_status => TradeStatus::SUCCESS,
              :answer_id => answer.id,
              :winner_id => answer.user.id
            )
          end
        end
        if question.credit > 0
          answer.user.update_attribute(:credit , answer.user.credit  + question.credit )
          order = CreditTransaction.new(
            :user_id => answer.user.id,
            :question_id => question.id,
            :answer_id => answer.id,
            :value => question.credit,
            :payment => false,
            :trade_type => TradeType::ACCEPT,
            :trade_status => TradeStatus::SUCCESS
          )
          order.save
          
          # change question user's order status from normal to success
          orders = current_user.credit_transactions.where(:question_id => question.id, :trade_type => TradeType::ASK)
          orders.each do |order|
            order.update_attributes(
              :trade_status => TradeStatus::SUCCESS,
              :answer_id => answer.id,
              :winner_id => answer.user.id
              )
          end
        end
      end
    end
    redirect_to question
  end
  
  protected
    def vote_init
      @answer = Answer.select("id").find_by_id(params[:id])
      @voted = @answer.trivalent_voted_by? current_user
    end
end
