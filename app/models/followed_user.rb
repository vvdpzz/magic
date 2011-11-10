class FollowedUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :follower
end
