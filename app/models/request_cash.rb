class RequestCash < ActiveRecord::Base
  set_primary_key 'id'
  belongs_to :user
  
  before_create :generate_uuid
  default_scope order("created_at DESC")
  
  def generate_uuid
    self.id = Time.now.strftime("%y%m%d%H%M%S") + UUIDList.pop[0..3]
  end
end
