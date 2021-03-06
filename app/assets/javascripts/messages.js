var conversations = {};


var messageFriendToken;
var recipientToken = null;
var dialogOpened = false;
var sendButtonDisabled = true;
var sendButton = null;

var userList = null;
var userSelector = null;
var initialized = false;

var isFirst = true;

var init = function() {
  loadConversations();
  initMessageBox();
  $('#new-msg-btn').click(sendMessageOnConversationView);
}

var loadConversations = function() {
  $.get('/messages/load_conversations', {},
    function(data) {
      if (data.length > 0){
        $('#messagebox-and-messages').show();
        $.each(data, function(idx, conversation) {
          conversations[conversation.friend_token] = conversation;
          var elem = constructConversationBox(conversation);
          elem.prependTo('#stream-items');
        });
        con = data[data.length-1];
        loadMessages(con.friend_token, con.friend_name);
        isFirst = false;
      }
    }
  );
};
var constructConversationBox = function(data) {
  var box = $('#stream-item-id').clone().show()
            .attr('id', 'stream-item-' + data.friend_token)
            .data('friendToken', data.friend_token)
            .click(function() {
              loadMessages(data.friend_token, data.friend_name);
            });
  box.find('.message-inner img').attr('src', data.friend_picture);
  box.find('.user-name strong').html(data.friend_name);
  box.find('.created-at ._timestamp').html(data.last_update);
  return box;
};
var loadMessages = function(friend_token, friend_name) {
  // add focus style to the conversation itme clicked at left
  $('#stream-item-' + friend_token).addClass('focused-stream-item').siblings().removeClass('focused-stream-item');
  
  // clear the messages below div-'messages-items'
  var item = $('#message-item-id');
  $('#messages-items').empty();
  item.appendTo('#messages-items');
  // add messages
  var messages = conversations[friend_token].messages;
  $.each(messages, function(idx, message) {
    var elem = constructMessageBox(message);
    elem.prependTo('#messages-items');
  });
  $('.twtf-box-title h2').html('给 ' + friend_name + ' 发私信');
  messageFriendToken = friend_token;
}
var constructMessageBox = function(data) {
  var box = $('#message-item-id').clone().show()
              .attr('id', 'message-entry-' + (new Date()).getTime());

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
  var message = {
    owner_name : viewer.name,
    owner_picture : viewer.avatar,
    owner_profile_url : '/users/' + viewer.id,
    time_created : dateFormat(new Date()),
    text : messageText
  };
  var e = constructMessageBox(message);
  e.prependTo('#messages-items');
  conversations[messageFriendToken].messages.push(message);
}
var getUserInfoByToken = function(token) {
	var matched = $.grep(userList, function(user) {
		return user.id == token;
	});
	return matched.length == 0 ? null : matched[0];
}


// init message dialog
var initMessageDialog = function(){
  initialized = true;
  sendMessageDialog = {
    autoOpen: false,
    modal: true,
    width: 500,
    height: 285,
    resizable: false,
    title: '发送私信',
    dialogClass: 'dlg-container-send-message',
    draggable: false,
    beforeClose: function() {
      dialogOpened = false;
      resetMessageDialog();
    },
    buttons: {
      发送: function() {
        if (!sendButtonDisabled)
        submitMessage();
      }
    }
  };
  $('#dlg-send-message').dialog(sendMessageDialog);
	$('#message-body textarea')
      .bind('keyup', updateSendButtonState)
      .bind('blur', updateSendButtonState)
      .bind('focus', messageTextOnFocus)
      .val('');
  addRecipientInputBox();
  sendButton = $('.dlg-container-send-message .ui-dialog-buttonpane button:last');
  disableSendButton();
  
  // $('#new-msg-btn').click(function(){
  //   $('#dlg-send-message').dialog('open');
  //   disableSendButton();
  // });
}
var updateSendButtonState = function() {
  var messageText = getMessageText();
  if (!recipientToken || !messageText)
    disableSendButton();
  else
    enableSendButton();
}
var messageTextOnFocus = function() {
	userSelector.hide();
}
var getMessageText = function() {
  return $('#message-body textarea').val();
}
var disableSendButton = function() {
  sendButton.addClass('ui-state-disabled');
  sendButtonDisabled = true;
}
var enableSendButton = function() {
  sendButton.removeClass('ui-state-disabled');
  sendButtonDisabled = false;
}
var addRecipientInputBox = function() {
  var recipientInput = "<input type='text' id='msg-user-input'/>";
  $(recipientInput).appendTo($('#message-recipient'))
                  .placeholder().focus();
  userSelector.bindInputElement('#msg-user-input');
  userSelector.refresh();
}
var submitMessage = function() {
  sendButtonDisabled = true;
  var messageText = getMessageText();
  $.post('/messages/send_message', {
    'recipient_token' : recipientToken,
    'text' : messageText
  }, function(res){
    if (res.rc) {
      sendButtonDisabled = false;
    } else {
      var cb = $('#dlg-send-message').data('successCallback');
      if (cb)
        cb(recipientToken, messageText);
      $('#dlg-send-message').dialog('close');
    }
  });
}

var resetMessageDialog = function() {
  if (recipientToken)
    removeRecipient();
  $('#message-body textarea').val('');
  $('#message-recipient input').val('');
  userSelector.clear();
  userSelector.hide();
  $('#dlg-send-message').data('successCallback', null);
}
var removeRecipient = function() {
  $('#message-recipient .recipient-name').remove();
  $('#message-recipient .remove-button').remove();
  userSelector.clear();
  addRecipientInputBox();
  recipientToken = null;
  disableSendButton();
}
var submitMessage = function() {
  sendButtonDisabled = true;
  var messageText = getMessageText();
  ajaxJson('/messages/send_message', {
    'recipient_token' : recipientToken,
    'text' : messageText
  }, function(res){
    if (res.rc) {
      sendButtonDisabled = false;
    } else {
      var cb = $('#dlg-send-message').data('successCallback');
      if (cb)
      cb(recipientToken, messageText);
      $('#dlg-send-message').dialog('close');
    }
  });
}
var loadUserConnectionList = function(profileOwner) {
  userSelector = new msgUserSelector(); 
  ajaxJsonGet('/messages/load_contact_list', {
  }, function(data) {	
    userList = data.contact_list;
    if (profileOwner) {
      var isOwnerInList = false;
      for (var i = 0; i < data.contact_list.length; i++)
      if (data.contact_list[i].token == profileOwner.token) {
        isOwnerInList = true;
        break;
      }
      if (!isOwnerInList)
      data.contact_list.push(profileOwner);
    }
    userSelector.userList = data.contact_list; 
  });
}
var selectRecipient = function(user) {
  $('#message-recipient input').remove();
  $('#message-recipient .recipient-name').remove();
  $('#message-recipient .remove-button').remove();

  var userSpan = "<span class='recipient-name'>" + stringutil.cut(user.name, 35) + "</span><span class='remove-button'></span>";
  $('#message-recipient').append(userSpan);
  $('#message-recipient .remove-button').click(removeRecipient);

  recipientToken = user.id;

  updateSendButtonState();
}
var sendMessageOnConversationView = function() {
	sendPrivateMessage(null, addNewMessageToConversation);
}
var sendPrivateMessage = function(user, successCallback) {
	if (!userSelector) {
		loadUserConnectionList(user);
	}  
  if (!initialized) {
    initMessageDialog();
  }
	$('#dlg-send-message').dialog('open');
	dialogOpened = true;

	if (successCallback) {
		$('#dlg-send-message').data('successCallback', successCallback);
	}
	if (user) {
		selectRecipient(user);
		$('#message-body textarea').focus();
	} else {
		$('#message-recipient input').focus();
	}
}
var addNewMessageToConversation = function(friendToken, messageText) {
  var box = $('#stream-item-' + friendToken);
  var message = {
    owner_name : viewer.name,
    owner_picture : viewer.avatar,
    owner_profile_url : 'users/' + viewer.id,
    time_created : dateFormat(new Date()),
    text : htmlEscape(messageText)
  }
  if (box.length == 1) {
    box.find('.created-at ._timestamp').html('1 second ago');
    conversations[friendToken].last_update = '1 second ago';
    conversations[friendToken].messages.push(message);
    
    if(friendToken == messageFriendToken){
      $('#messages-items').prepend(constructMessageBox(message));
    }
  } else {
    var friend = getUserInfoByToken(friendToken);
    var messages = new Array(message);
    var conversation = {
      'friend_token' : friendToken,
      'friend_picture' : friend.avatar,
      'friend_name' : friend.name,
      'unread_message_count' : 0,
      'last_update' : dateFormat(new Date()),
      'messages' : messages
    }
    box = constructConversationBox(conversation);
    box.prependTo('#stream-items');
    conversations[friendToken] = conversation;
    if (isFirst){
      $('#messagebox-and-messages').show();
      loadMessages(friendToken, friend.name);
      isFirst = false;
    }  
  }
  // $('#conversations-empty').hide();
};





msgUserSelector = function() {
  var superClass = new Selector({
    dropdownClass: "user-selector-list",
    rowClass: "user-entry-item",
    defaultMsg : "输入您关注的人..."
  });

  superClass.userList = [];

  var sortUser = function(a, b) {
    return a.name.toLowerCase() < b.name.toLowerCase() ? -1 : 1;
  }

  var matchUsers = function(userList, pat) {
    var firstClassMatch = [];
    var secondClassMatch = [];
    pat = pat.toLowerCase();
    if (!pat) {
      return []
    }
    $.each(userList, function(idx, userObj) {
      var name = userObj.name.toLowerCase();
      var pos = name.indexOf(pat);
      if (pos == 0)
      firstClassMatch.push(userObj);
      else if (pos > -1)
      secondClassMatch.push(userObj);
    });
    firstClassMatch.sort(sortUser);
    secondClassMatch.sort(sortUser);
    return firstClassMatch.concat(secondClassMatch);
  }

  superClass.constructRow = function(idx, rowObj) {
    var row = "<div class='user-entry-item' index=" + idx + ">";
    row += "<img src='" + rowObj.avatar + "'>";
    row += "<span>" + rowObj.name + "</span>";
    row += "</div>";
    return $(row);
  }

  superClass.refresh = function() {
    if (!dialogOpened) {
      return false;
    }
    var value = $.trim($(superClass.inputElem).val());
    var list = matchUsers(superClass.userList, value);
    superClass.refreshList(list);
  }

  superClass.onEnter = function(e) {
    return;
  }

  superClass.onSelect = function(idx) {
    var user = superClass.list[idx];
    selectRecipient(user);
  }

  return superClass;
};