var messageFriendToken;
var dialogOpened = false;
var loadConversations = function() {
  $.get('/messages/load_conversations', {},
    function(data) {
      if (data.length > 0){
        $('#messagebox-and-messages').show();
        $.each(data, function(idx, conversation) {
          var elem = constructConversationBox(conversation);
          elem.prependTo('#stream-items');
        });
        loadMessages(data[0]);
        initMessageBox();
      }
    }
  );
};
var constructConversationBox = function(data) {
  var box = $('#stream-item-id').clone().show()
            .attr('id', 'stream-item-' + data.friend_token)
            .data('friendToken', data.friend_token)
            .click(function() {
              loadMessages(data);
            });
  box.find('.message-inner img').attr('src', data.friend_picture);
  var friendName = data.friend_name;
  if (data.unread_message_count > 0)
    friendName += ' (' + data.unread_message_count + ')';
  box.find('.user-name strong').html(friendName);
  // box.find('.conversation-info .message-preview').html(data.last_message);
  box.find('.created-at ._timestamp').html(data.last_update);
  return box;
};
var loadMessages = function(data) {
  $.each(data.messages, function(idx, message) {
    var elem = constructMessageBox(message);
    elem.prependTo('#messages-items');
  });
  $('.tweet-box-title h2').html('给 ' + data.friend_name + ' 发信息');
  messageFriendToken = data.friend_token;
}
var constructMessageBox = function(data) {
  var box = $('#message-item-id').clone().show()
              .attr('id', 'message-entry-' + data.message_token);

  box.find('.message-inner a').attr('href', data.owner_profile_url);
  box.find('.message-inner img').attr('src', data.owner_picture);
  box.find('.user-name .user-profile-link').html(data.owner_name).attr('href', data.owner_profile_url);
  box.find('.created-at ._old-timestamp').html(data.time_created);
  box.find('.message-content .linked-text').html(data.text);
  return box;
}
var initMessageBox = function() {
  $('.text-area textarea').bind('keyup', updateReplyButtonState)
                          .bind('blur', updateReplyButtonState);
  $('#btn-reply-message').click(function(){
    replyMessage();
  });
}
var updateReplyButtonState = function() {
  var msg = $('.text-area textarea').val();
  if (msg.length > 0) {
    $('#btn-reply-message').removeClass('disabled');
  } else {
    $('#btn-reply-message').addClass('disabled');
  }
}
var replyMessage = function() {
  if($('#btn-reply-message').hasClass('disabled'))
    return;
  $('#btn-reply-message').addClass('disabled');
  var messageText = $('.text-area textarea').val();
  $.post('/messages/send_message', {
    'recipient_token' : messageFriendToken,
    'text' : messageText
  }, function(res){
    if (res.rc) {
      $('#btn-reply-message').removeClass('disabled');
    } else {
      showNewMessage(htmlEscape(messageText));
      $('.text-area textarea').val('');
    }
  });
}
var showNewMessage = function(messageText) {
  var e = constructMessageBox({
    owner_name : viewer.name,
    owner_picture : viewer.avatar,
    owner_profile_url : 'users/' + viewer.id,
    time_created : '1 秒钟前',
    text : messageText
  });
  e.prependTo('#messages-items');
}
var htmlEscape = function(txt) {
  return txt.replace(/&/g,'&amp;').                                         
              replace(/>/g,'&gt;').                                           
              replace(/</g,'&lt;').                                           
              replace(/"/g,'&quot;')              
}

// init message dialog
var initMessageDialog = function(){
  sendMessageDialog = {
    initialized : false,
    autoOpen: false,
    modal: true,
    width: 500,
    height: 325,
    resizable: false,
    title: 'New Message',
    dialogClass: 'dlg-container-send-message',
    draggable: false,
    beforeClose: function() {
      dialogOpened = false;
      // resetMessageDialog();
    },
    buttons: {
      Send: function() {
        if (!sendButtonDisabled)
        submitMessage();
      }
    }
  };
  $('#dlg-send-message').dialog(sendMessageDialog);
	$('#message-body textarea')
  $('#new-msg-btn').click(function(){
    $('#dlg-send-message').dialog('open');
  });
}