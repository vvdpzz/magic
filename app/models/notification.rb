# encoding: utf-8
class Notification < ActiveRecord::Base
  include Extensions::UUID
  belongs_to :user, :counter_cache => true
  
  default_scope order("created_at DESC")
  
  def self.sql_update_is_read
    ActiveRecord::Base.connection.execute("update notifications set is_read = 1")
  end
  
  def self.create_and_push(current_user, type, user = nil, question = nil, answer = nil)
    #type=1 follow somebody
    if type == 1
      html = "<a href='/users/#{current_user.id}'>#{current_user.name}</a> 关注了你。"
      notification = Notification.create(:user_id => user.id, :content => html)
      $redis.incr("notifications:#{user.id}:unreadcount")
      Pusher["presence-notifications_#{user.id}"].trigger('notification_created', MultiJson.encode(notification))
    #type=2 entry a answer
    elsif type == 2
      html = "<a href=\"/users/#{current_user.id}\">#{current_user.name}</a> 回答了你的问题 <a href=\"/questions/#{question.id}\">#{question.title}</a> 。"
      notification = Notification.create(:user_id => question.user_id, :content => html)
      $redis.incr("notifications:#{question.user_id}:unreadcount")
      Pusher["presence-notifications_#{question.user_id}"].trigger('notification_created', MultiJson.encode(notification))
    #type=3 accept the answer
    elsif type == 3
      html = "<a href=\"/users/#{current_user.id}\">#{current_user.name}</a> 采纳了你对 <a href=\"/questions/#{answer.question_id}\">#{answer.question.title}</a> 的回答 。"
      notification = Notification.create(:user_id => answer.user_id, :content => html)
      $redis.incr("notifications:#{answer.user_id}:unreadcount")
      Pusher["presence-notifications_#{answer.user_id}"].trigger('notification_created', MultiJson.encode(notification))
    #type=4 vote for the answer
    elsif type == 4
      html = "<a href=\"/users/#{current_user.id}\">#{current_user.name}</a> 给你对问题 <a href=\"/questions/#{answer.question_id}\">#{answer.question.title}</a> 的回答投了正票。"
      notification = Notification.create(:user_id => answer.user_id, :content => html)
      $redis.incr("notifications:#{answer.user_id}:unreadcount")
      Pusher["presence-notifications_#{answer.user_id}"].trigger('notification_created', MultiJson.encode(notification))
    end
  end
end
