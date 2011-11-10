# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('a#follow-user').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.flag
          link.removeClass('success').addClass('normal').html("取消关注")
        else
          link.removeClass('normal').addClass('success').html("关 注")
    false
  
  $('a#favorite-question').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.favorited
          link.removeClass('green').addClass('white').html("取消收藏")
        else
          link.removeClass('white').addClass('green').html "收藏"
    false
  
  $('.btn#followed_question').click ->
    link = $(this)
    $.ajax
      type: "PUT"
      url: this.href
      success: (data)->
        if data.status
          link.removeClass('success').html("取消关注")
        else
          link.addClass('success').html "添加关注"
    false
