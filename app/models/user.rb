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
  has_many :favorite_questions, :class_name => "FavoriteQuestion", :foreign_key => "user_id", :conditions => {:status => true}
  has_many :followed_questions, :class_name => "FollowedQuestion", :foreign_key => "user_id", :conditions => {:status => true}
  has_many :followers, :class_name => "FollowedUser", :foreign_key => "user_id"
  has_many :following, :class_name => "FollowedUser", :foreign_key => "follower_id"
  
  has_one :photo
  
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
  
  def followers_inredis
    uids = $redis.smembers("users:#{self.id}.follower_users")
    users = User.find(uids)
  end
  
  def followings_inredis
    uids = $redis.smembers("users:#{self._id}.following_users")
    users = User.find(uids)
  end
  
  def followings_count
    $redis.scard("users:#{self.id}.following_users")
  end
  
  def followers_count
    $redis.scard("users:#{self.id}.follower_users")
  end
  
end
