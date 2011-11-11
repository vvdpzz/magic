class QuestionsController < ApplicationController
  before_filter :vote_init, :only => [:vote_for, :vote_against]
  
  def index
    @questions = Question.paid.page(params[:page]).per(Settings.questions_per_page)
    @url = "/questions"
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def paid
    @questions = Question.paid.page(params[:page]).per(Settings.questions_per_page)
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end
  
  def free
    @questions = Question.free.page(params[:page]).per(Settings.questions_per_page)
    respond_to do |format|
      format.html {render :layout => false}
      format.js
    end
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build params[:question]
    respond_to do |format|
      if @question.save
        @question.save and @question.deduct_credit and @question.order_credit and @question.deduct_reputation and @question.order_reputation
        format.html { redirect_to @question, :notice => 'Question was successfully created.' }
        format.json { render :json => @question, :status => :ok, :location => @question }
      else
        format.html { render :action => "new" }
        format.json { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @question = Question.find params[:id]
  end

  def destroy
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
      if current_user.vote_for @question
        @question.update_attribute(:votes_count, @question.plusminus)
        render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
      end
    else
      if current_user.vote_exclusively_for @question
        @question.update_attribute(:votes_count, @question.plusminus)
        render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
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
      if current_user.vote_against @question
        @question.update_attribute(:votes_count, @question.plusminus)
        render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
      end
    else
      if current_user.vote_exclusively_against @question
        @question.update_attribute(:votes_count, @question.plusminus)
        render json: {:id => @question.id, :votes_count => @question.plusminus}, status: :ok
      end
    end
  end
  
  def follow
    question = Question.find params[:id]
    status = true
    if question
      records = FollowedQuestion.where(:user_id => current_user.id, :question_id => question.id)
      if records.empty?
        current_user.followed_questions.create(:question_id => question.id)
      else
        record = records.first
        status = record.status if record.update_attribute(:status, !record.status)
      end
      render :json => {:status => status}
    end
  end
  
  def favorite
    question = Question.find params[:id]
    status = true
    if question
      records = FavoriteQuestion.where(:user_id => current_user.id, :question_id => question.id)
      if records.empty?
        current_user.favorite_questions.create(:question_id => question.id)
      else
        record = records.first
        status = record.status if record.update_attribute(:status, !record.status)
      end
      render :json => {:status => status}
    end
  end
  
  def watch
    l = "list:#{current_user.id}:watched"
    items = $redis.lrange(l, 0, -1)
    @list = items.collect{ |item| $redis.lrange(item, 0, -1) }
  end
  
  protected
    def vote_init
      @question = Question.select("id").find_by_id(params[:id])
      @voted = @question.trivalent_voted_by? current_user
    end
end
