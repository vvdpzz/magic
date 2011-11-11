class User < ActiveRecord::Base
  include Extensions::UUID
  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :invitable, :token_authenticatable, :database_authenticatable,
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
  has_many :followers, :class_name => "FollowedUser", :foreign_key => "user_id"
  has_many :following, :class_name => "FollowedUser", :foreign_key => "follower_id"
  
  has_one :photo
  
  attr_writer :invitation_instructions

  def deliver_invitation
    if @invitation_instructions
      ::Devise.mailer.send(@invitation_instructions, self).deliver
    else
      super
    end
  end

  def self.invite_guest!(attributes={}, invited_by=nil)
    self.invite!(attributes, invited_by) do |invitable|
      invitable.invitation_instructions = :guest_invitation_instructions
    end
  end

  def self.invite_friend!(attributes={}, invited_by=nil)
    self.invite!(attributes, invited_by) do |invitable|
      invitable.invitation_instructions = :friend_invitation_instructions
    end
  end
  
  def gavatar
    if self.avatar == ""
      return "/assets/default.png"
    else
      return self.avatar
    end
  end

  acts_as_voter
  
  def self.basic(id)
    User.select("id,name,avatar").find_by_id(id)
  end
  
  def has_relationship_redis(user_id)
    $redis.sismember("users:#{user_id}.following_users", self.id)
  end
  
  def has_relationship_db(user_id,follower_id)
    FollowedUser.where(:user_id => user_id, :follower_id => follower_id, :flag => true)
  end
  
end
