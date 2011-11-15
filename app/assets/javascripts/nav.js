var initNav = function() {
  loadMessagesOnNav();
}

var loadMessagesOnNav = function() {
  ajaxJsonGet('/messages/load_messages_on_navbar', {},
    function(data) {
      if(data.count > 0)
        $('#nav-msg-new-num').text(data.count).show();
    }
  );
}