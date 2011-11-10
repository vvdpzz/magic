# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  user_accout = {
    credit : 0,
    reputation : 0
  }
  question_paymentDlg = {
    title : "赏金支付",
    autoOpen: false,
    modal: true,
    width: 575,
    height: 435,
    resizable: false,
    buttons: 
      '取消': ()-> 
        $.get "/cash", (data, textStatus, xhr) ->
          user_accout.credit = data.credit
          userReputation = data.reputation
          needRecharge = parseInt($("#question_credit").val())-user_accout.credit
          if needRecharge > 0
            $("#credit_tips").text("您余额不足，请充值"+needRecharge+"元")
          else
            $("#credit_tips").fadeOut()
            $("#question_credit").closest('.clearfix').removeClass('error')
            $("#question_credit").removeClass("xlarge error")
        $(this).dialog("close")
      '充值':()->
        $($("#payment-form").get(0).utf8).remove()
        url = "https://www.alipay.com/cooperate/gateway.do?" + $("#payment-form").serialize()
        window.open url, "_blank"
        $(this).dialog("option",question_paymentDlg_reTry)
  }
  
  needRecharge = 0;
  question_paymentDlg_reTry = {
    buttons:
      '完成':()->
        $.get "/cash", (data, textStatus, xhr) ->
          user_accout.credit = data.credit
          if $('#question_credit').val() <= user_accout.credit
            $("#reCharge").fadeOut()
          else
            needRecharge = parseInt($("#question_credit").val())-user_accout.credit
            $("#credit_tips").text("您余额不足，请充值"+needRecharge+"元")
        $(this).dialog("close")
      '重试':()->
        url = "https://www.alipay.com/cooperate/gateway.do?" + $("#payment-form").serialize()
        window.open url, "_blank"
  }
  $('#addedRule').bind 'mouseup',->
    if $('#additional_rule').css('display') is 'none'
      $('#additional_rule').slideDown(200)
    else
      $('#additional_rule').slideUp(300)
      $("#new_question").submit -> 
      isSubmit = true
      isRecharge = false
      #init element style
      $("#contentCount").hide();
      $("#question_credit").closest('.clearfix').removeClass('error')
      $("#question_credit").removeClass("xlarge error")
      $("#question_credit").closest('.clearfix').removeClass('error')
      $("#question_credit").removeClass("xlarge error")
      
      #into judge block
      unless $("#question_title").val().length
        $('#titleCount').text('请输入标题')
        isSubmit = false
      unless $(".nicEdit-main").text().length
        $("#contentCount").text('请完善内容')
        isSubmit = false
      unless ($("#question_credit").val() is "0.0")
        unless checkNum($("#question_credit").val())
          $("#question_credit").closest('.clearfix').addClass('error')
          $("#question_credit").addClass("xlarge error")
          $("#credit_tips").text("请输入正确金额")
          isSubmit = false
        if(parseInt($("#question_credit").val()) > user_accout.credit)
          $("#question_credit").closest('.clearfix').addClass('error')
          $("#question_credit").addClass("xlarge error")
          needRecharge = parseInt($("#question_credit").val(),10)-user_accout.credit
          $("#credit_tips").text("您余额不足，请充值"+needRecharge+"元")
          isRecharge = true
          $("#into_recharge").fadeIn()
          $("#into_recharge").bind "click",->
            $.get "/cash", (data, textStatus, xhr) ->
              user_accout.credit = data.credit
              userReputation = data.reputation
              if isRecharge
                $.ajax
                  url: "/recharge/generate_order"
                  type: "POST"
                  dataType: "json"
                  data:{credit: user_accout.credit}
                  success: (data, textStatus, xhr) ->
                    $("#order_number").html data.order_id
                    $("#order_credit").text "您要支付的金额为："+(parseInt($("#question_credit").val(),10)-data.order_credit)+"元"
                    $("#alipay_form").html data.html
              $("#dialog_payment").dialog(question_paymentDlg)
              $("#dialog_payment").dialog('open')
          isSubmit = false
      unless checkNum($("#question_reputation").val())
        $("#question_reputation").closest('.clearfix').addClass('error')
        $("#question_reputation").addClass("xlarge error")
        $("#reputation_tips").text("请输入正确的数值")
        $("#question_reputation").addClass("xlarge error")
        isSubmit = false
      if(parseInt($("#question_reputation").val()) > userReputation)
        $("#question_reputation").closest('.clearfix').addClass('error')
        $("#question_reputation").addClass("xlarge error")
        needReputation = parseInt($("#question_reputation").val()) - userReputation
        $("#reputation_tips").text("您的积分不足，缺少"+needReputation+"积分")
        isSubmit = false
       false unless isSubmit
  $("#question_title").bind "keydown",()->
    numCountDown($('#question_title'),$('#titleCount'),70)
  $('.nicEdit-main').bind "keydown",()->
    numCountDown($('.nicEdit-main'),$('#contentCount'),1000)
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
  return true