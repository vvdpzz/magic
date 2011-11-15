# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('.btn#follow-user').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.flag
          link.removeClass('success').html("取消关注")
        else
          link.addClass('success').html("关 注")
    false
  
  $('.btn#favorited-question').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.status
          link.removeClass('success').html("取消收藏")
        else
          link.addClass('success').html("收藏问题")
    false
  
  $('.btn#followed-question').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.status
          link.removeClass('success').addClass('normal').html("取消关注")
        else
          link.addClass('success').removeClass('normal').html("关注问题")
    false
    
  $('#profile-send-message').click ->
    sendPrivateMessage(profileOwner)
