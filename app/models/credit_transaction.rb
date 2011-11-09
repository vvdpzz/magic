class CreditTransaction < ActiveRecord::Base
  has_enumeration_for :trade_type, :with => ::TradeType
  has_enumeration_for :trade_status, :with => ::TradeStatus
  
  belongs_to :user
  belongs_to :question
  belongs_to :answer
end
