class Answer < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true
  belongs_to :question, :counter_cache => true
  has_many :comments, :class_name => "Comment", :foreign_key => "magic_id", :dependent => :destroy
  default_scope order("created_at DESC")
  
  validate :enough_reputation_to_pay

  def enough_reputation_to_pay
    if self.question.not_free? and self.question.correct_answer_id == 0 and self.user.reputation < 5
      errors.add(:reputation, "you do not have enough reputation to pay.")
    end
  end
  
  acts_as_voteable
  
  def deduct_reputation
    self.user.update_attribute(:reputation, self.user.reputation - Settings.answer_price) if self.question.not_free?
  end
  
  def order_reputation
    ReputationTransaction.create(
      :user_id => self.user.id,
      :question_id => self.question.id,
      :answer_id => self.id,
      :value => Settings.answer_price,
      :trade_type => TradeType::ANSWER,
      :trade_status => TradeStatus::NORMAL
    )
  end
end
