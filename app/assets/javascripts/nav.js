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
        $('#msg_warpper_container').append(elem);
      });
      if(data.count > 0){
        $('#nav-ntf-new-num').text(data.count).show();
      }
    }
  }
);
}

var contructNotificationItem = function(notification) {
  var item = $('#itemBox').clone().show().removeAttr('id');
  item.find('p').html(notification.content);
  item.find('.notification-time').html(dateFormat(new Date(notification.created_at)));
  return item;
}