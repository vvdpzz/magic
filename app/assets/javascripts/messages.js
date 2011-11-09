var loadConversations = function() {
  $.get('/messages/load_conversations', {},
    function(data) {
      if (data.length > 0){
        $('#messagebox-and-messages').show();
        $.each(data, function(idx, conversation) {
          var elem = constructConversationBox(conversation);
          elem.appendTo('#stream-items');
        });
        loadMessages(data[0]);
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
    elem.appendTo('#messages-items');
  });
  $('.tweet-box-title h2').html('给 ' + data.friend_name + ' 发信息');

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
var initMessageView = function() {
  $('.text-area textarea').bind('keyup', updateReplyMessageCountdown)
                          .bind('blur', updateReplyMessageCountdown);
  $('#reply-message-countdown').text(messageTextLimit);
  $('#btn-reply-message').click(function(){
    replyMessage(messageFriendToken);
  });
  $('#btn-back-to-conversations').click(function(){
    ce6.site.redirect('messages/conversations');
  });
}