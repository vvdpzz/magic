# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $('#addedRule').bind 'mouseup',->
    if $('#additional_rule').css('display') is 'none'
      $('#additional_rule').slideDown(200)
    else
      $('#additional_rule').slideUp(300)
  $("#new_question").submit ->
    isSubmit = true
    if $("#question_title").val().length is 0
      $('#titleCount').text('请输入标题')
      isSubmit = false
    if $(".nicEdit-main").text().length is 0
      $("#contentCount").text('请完善内容')
      isSubmit = false
    if checkNum($("#question_credit").val()) is false
      $("#question_credit").closest('.clearfix').addClass('error')
      $("#question_credit").addClass("xlarge error")
      $("#credit_tips").text("请输入正确金额")
      isSubmit = false
    if checkNum($("#question_reputation").val()) is false
      $("#reputation_tips").text("请输入正确的数值")
      $("#question_reputation").addClass("xlarge error")
      isSubmit = false
    false unless isSubmit
  #bind   
  $("#question_title").bind "keydown",()->
    numCountDown($('#question_title'),$('#titleCount'),70)
  $('.nicEdit-main').bind "keydown",()->
    numCountDown($('.nicEdit-main'),$('#contentCount'),1000)
  
  return
)
numCountDown = (input,num,len)->
  input = input.val()
  numDiv = num
  length = len
  inputCount = input.length
  if input
    inputCount = length - inputCount
    if inputCount < 0
      numDiv.addClass('negative')
    numDiv.text inputCount
  else
    numDiv.text length

checkNum = (str)->
  mynumber="0123456789"; 
  i = 0
  if(str.length is 0)
    return false
  while i < str.length
    c=str.charAt(i)
    if(mynumber.indexOf(c) is -1) 
      return false
    i++        
true