class Comment < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true
  belongs_to :question, :class_name => "Question", :foreign_key => "magic_id", :counter_cache => true
  belongs_to :answer, :class_name => "Answer", :foreign_key => "magic_id", :counter_cache => true
end
