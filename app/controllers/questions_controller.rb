class QuestionsController < ApplicationController
  before_filter :vote_init, :only => [:vote_for, :vote_against]
  
  def index
    @questions = Question.paid.page(params[:page]).per(Settings.questions_per_page)
    @top_prize_questions = Question.find_by_sql("select * from questions order by credit desc, created_at DESC").first(5)
    @hot_questions = Question.find_by_sql("select * from questions order by answers_count desc, created_at DESC").first(5)
    @recent_winners = CreditTransaction.where("winner_id != 0").order("updated_at desc").first(5)
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
      format.json { render :json => @questions, :status => :ok }
    end
  end
  
  def free
    @questions = Question.free.page(params[:page]).per(Settings.questions_per_page)
    respond_to do |format|
      format.html {render :layout => false}
      format.js
      format.json { render :json => @questions, :status => :ok } 
    end
  end

  def new
    @question = Question.new
  end

  def create
    params[:question][:rules_list] = params[:question][:rules_list].reject(&:blank?).to_param
    @question = current_user.questions.build params[:question]
    @question.id = UUIDList.pop
    respond_to do |format|
      puts @question.reputation
      puts @question.credit
      if @question.valid?
        @question.strong_create_question
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
    q_hash = @question.serializable_hash
    q_data = q_hash.merge! User.basic_hash @question.user_id
    answers = Answer.where(:question_id => params[:id])
    a_hash = answers.collect{ |answer| answer.serializable_hash.merge!(User.basic_hash answer.user_id)}
    q_data = q_data.merge!({:answers => a_hash})
    respond_to do |format|
      format.html
      format.json { render :json => q_data, :status => :ok } 
    end
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
      record = FollowedQuestion.where(:user_id => current_user.id, :question_id => question.id).first
      of_count = current_user.followed_questions_count
      oq_count = question.followed_questions_count
      if record.blank?
        current_user.followed_questions.create(:question_id => question.id)
        current_user.update_attribute(:followed_questions_count, of_count+1)
        question.update_attribute(:followed_questions_count, oq_count+1)
      else
        if record.status
           current_user.update_attribute(:followed_questions_count, of_count-1)
           question.update_attribute(:followed_questions_count, oq_count-1)
         else
           current_user.update_attribute(:followed_questions_count, of_count+1)
           question.update_attribute(:followed_questions_count, oq_count+1)
         end
        status = record.status if record.update_attribute(:status, !record.status)
      end
      render :json => {:status => status}
    end
  end
  
  def favorite
    question = Question.find params[:id]
    status = true
    if question
      record = FavoriteQuestion.where(:user_id => current_user.id, :question_id => question.id).first
      of_count = current_user.favorite_questions_count
      oq_count = question.favorite_questions_count
      if record.blank?
        current_user.favorite_questions.create(:question_id => question.id)
      else
        if record.status
           current_user.update_attribute(:favorite_questions_count, of_count-1)
           question.update_attribute(:favorite_questions_count, oq_count-1)
         else
           current_user.update_attribute(:favorite_questions_count, of_countunt+1)
           question.update_attribute(:favorite_questions_count, oq_count+1)
         end
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
