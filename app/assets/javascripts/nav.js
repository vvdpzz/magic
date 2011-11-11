var initNav = function() {
  loadMessagesOnNav();
  // $('#nav-msg-new-num').click(clickMessages);
}

var clickMessages = function() {
  if ($('#nav-msg-new-num').length) {
    ajaxJsonPost('/messages/update_last_viewed');
    $('#nav-msg-new-num').text('').hide();
  }
}

var loadMessagesOnNav = function() {
  ajaxJsonGet('/messages/load_messages_on_navbar', {},
    function(data) {
      if(data.count > 0)
        $('#nav-msg-new-num').text(data.count).show();
    }
  );
}