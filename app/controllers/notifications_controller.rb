class NotificationsController < ApplicationController
  
  def index
    @notification_list = current_user.notifications
    @has_notification = false
    if @notification_list.length > 0
      @first = @notification_list.first
      @has_notification = true
    end
  end
  
  def load_notifications
    @notifications = Notification.where(:user_id => current_user.id, :id_read => true )
    render :json => { :notification_list => @notifications }
    
  end

end