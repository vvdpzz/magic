class Question < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true  
  has_many :answers, :dependent => :destroy
  has_many :comments, :class_name => "Comment", :foreign_key => "magic_id", :dependent => :destroy
  default_scope order("created_at DESC")
  
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
          :magic_id => self.id,
          :value => self.send(name),
          :trade_type => TradeType::ASK,
          :trade_status => TradeStatus::NORMAL
        )
      end
    end
  end

  def could_answer_by?(user_id)
    self.answers.select('user_id').where(:user_id => user_id).empty?
  end
  
  def answered_by?(user_id)
    not self.answers.select('user_id').where(:user_id => user_id).empty?
  end
  
  def answer_for(user_id)
    self.answers.find_by_user_id(user_id)
  end
end
