var initNav = function() {
  loadMessagesOnNav();
  loadNotificationsOnNav();
}

var loadMessagesOnNav = function() {
  $.get('/messages/load_messages_on_navbar', {},
    function(data) {
      if(data.count > 0)
        $('#nav-msg-new-num').text(data.count).show();
    }
  );
}

var loadNotificationsOnNav = function() {
  $.get('/notifications/load_notifications_on_navbar', {},
  function(data) {
    if(data.notifications.length > 0) {
      $.each(data.notifications, function(idx, notification) {
        var elem = contructNotificationItem(notification);
        $('#notification-container').append(elem);
        $('#notification-container').append('<li class="divider"></li>')
      });
      if(data.count > 0){
        $('#nav-ntf-new-num').text(data.count).show();
      }
    }  
    $('#notification-container .divider:last').remove();
  }
);
}

var contructNotificationItem = function(notification) {
  var item = $('#notification-item').clone().show().removeAttr('id');
  item.find('p').html(notification.content);
  item.find('.notification-time').html(dateFormat(new Date(notification.created_at)));
  return item;
}