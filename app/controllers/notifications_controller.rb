class NotificationsController < ApplicationController
  
  def index
    @notification_list = current_user.notifications
    $redis.set("notifications:#{current_user.id}:unreadcount", 0)
    @has_notification = false
    if @notification_list.length > 0
      @first = @notification_list.first
      @has_notification = true
    end
  end
  
  def load_notifications_on_navbar
    notifications = Notification.where(:user_id => current_user.id, :is_read => false )
    unread_count = $redis.get("notifications:#{current_user.id}:unreadcount")
    render :json => { :count => unread_count, :notifications => notifications }
  end
  
  def set_unread_count
    $redis.set("notifications:#{current_user.id}:unreadcount", 0)
    render :json => { :rc => 0 }
  end

end