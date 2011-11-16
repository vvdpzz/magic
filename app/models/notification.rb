class Notification < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true
  
  default_scope order("created_at DESC")
end
