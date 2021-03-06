class Question < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true  
  has_many :answers, :dependent => :destroy
  has_many :comments, :class_name => "Comment", :foreign_key => "magic_id", :dependent => :destroy
  has_many :followed_questions, :class_name => "FollowedQuestion", :foreign_key => "question_id", :conditions => {:status => true}
  default_scope order("created_at DESC")
  scope :free, lambda { where(["reputation = 0 AND credit = 0.00"]) }
  scope :paid, lambda { where(["reputation <> 0 OR credit <> 0.00"])}
  acts_as_voteable
  
  def not_free?
    self.credit != 0 or self.reputation != 0
  end
  
  ["credit", "reputation"].each do |name|
    define_method "#{name}_rewarded?" do
      self.send(name) > 0
    end
    
    define_method "deduct_#{name}" do
      self.user.update_attribute(name.to_sym, self.user.send(name) - self.send(name)) if self.send(name) > 0
    end
    
    define_method "order_#{name}" do
      if self.send(name) > 0
        "#{name}_transaction".classify.constantize.create(
          :user_id => self.user.id,
          :question_id => self.id,
          :value => self.send(name),
          :trade_type => TradeType::ASK,
          :trade_status => TradeStatus::NORMAL
        )
      end
    end
  end

  def followed_users
    uids = FollowedQuestion.select('user_id').where(:question_id => self.id, :status => true).collect{ |item| item.user_id }
    User.select("id,name,avatar").find uids
  end

  def could_answer_by?(user_id)
     user_id != self.user_id  and not answered_by?(user_id)
  end
  
  def answered_by?(user_id)
    not self.answers.select('user_id').where(:user_id => user_id).empty?
  end

  def followed_dy?(user_id)
    records = FollowedQuestion.where(:user_id => user_id, :question_id => self.id)
    records.empty? ? false : records.first.status
  end
  
  def answer_for(user_id)
    self.answers.find_by_user_id(user_id)
  end
  
  def watched_user
      
  end
  
  def favorited_users
  end
end
