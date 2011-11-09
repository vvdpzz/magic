class User < ActiveRecord::Base
  include Extensions::UUID
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :name, :email, :avatar, :about_me, :password, :remember_me, :authentication_token
  before_create :ensure_authentication_token
  
  has_many :questions
  has_many :answers
  has_many :comments
  has_many :recharge_records
  has_many :reputation_transactions
  has_many :credit_transactions
  
  has_one :photo
  
  def gavatar
    self.avatar ||= "/assets/default-profile-photo.png"
  end

  acts_as_voter
end
