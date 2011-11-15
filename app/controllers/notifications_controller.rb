class NotificationsController < ApplicationController
  
  def index
    @notification_list = current_user.notifications
    @has_notification = false
    if @notification_list.length > 0
      @first = @notification_list.first
      @has_notification = true
    end
  end
  
  def load_notifications_on_navbar
    @notifications = Notification.where(:user_id => current_user.id, :is_read => true )
    render :json => { :notifications => @notifications }
    
  end

end