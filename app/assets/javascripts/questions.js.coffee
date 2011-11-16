# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(->
  $loadingImg = $("<img/>").attr('src', '/assets/loading.gif')
  #datepicker init
  datepickerOptions = {
    minDate: 3,
    maxDate: 30
    dateFormat: 'yy-mm-dd'
  }
  defaultEndDate = 3
  $("#question_datepicker").datepicker(datepickerOptions);
  today = new Date();
  endDate = new Date(today.getTime() + defaultEndDate * 86400 * 1000);
  $('#question_datepicker').datepicker('setDate', endDate);

  question_paymentDlg = {
    title : "赏金支付",
    autoOpen: false,
    modal: true,
    width: 575,
    height: 435,
    resizable: false,
    buttons: 
      '充值':()->
        $($("#payment-form").get(0).utf8).remove()
        url = "https://www.alipay.com/cooperate/gateway.do?" + $("#payment-form").serialize()
        window.open url, "_blank"
        $(this).dialog("option",question_paymentDlg_reTry)
      '取消': ()-> 
        $(this).dialog("close")
  }
  question_paymentDlg_reTry = {
    buttons:
      '完成':()->
        getUserCredit ()->
          if parseInt($('#select_credit').val(),10) <= user_accout.credit
            $("#recharge").fadeOut()
            removeDomError($("#select_credit"))
          else
            user_accout.needCredit = parseInt($("#select_credit").val(),10) - user_accout.credit
            $("#currentUserAccount").text("您当前金额为#{user_accout.credit}元")
            $("#credit_tips").text("还需充值"+user_accout.needCredit+"元")
          $('#dialog_payment').dialog("close")
        
      '遇到困难':()->
          
  }
  $("#new_question").submit ->
    #jquery object constant
    $contentTips = $("#contentTips")
    $question_credit = $("#select_credit")
    $question_title = $("#question_title")
    $titleCount = $('#titleCount')
    $question_reputation = $("#question_reputation")
    $reputation_tips = $("#reputation_tips")
    $credit_tips = $("#credit_tips")
    $recharge = $("#recharge")
    #condition bool
    isSubmit = true
    #init element style
    removeDomError($question_title,$contentTips,$question_reputation,$question_credit)
    $reputation_tips.fadeOut()
    $recharge.hide()
    #into condition block
    unless $question_title.val().length
      $titleCount.text('请输入标题')
      addDomError($titleCount)
      isSubmit = false
    unless $(".nicEdit-main").text().length
      addDomError($contentTips)
      isSubmit = false
  #credit importpart
    if $question_credit.val()!='0'
      $credit_tips.append($loadingImg)
      getUserCredit( ()->
        user_accout.needCredit = needRecharge = parseInt($question_credit.val(),10) - user_accout.credit
        if parseInt($question_credit.val(),10) > user_accout.credit
          addDomError($question_credit)
          $recharge.show()
          $("#currentUserAccount").text("您当前金额为#{user_accout.credit}元")          
          $credit_tips.text("请充值"+needRecharge+"元")
          $("#into_recharge").fadeIn()
          isSubmit = false
        $loadingImg.remove()
      )
      #get init userAccount
    unless checkNum($question_reputation.val())||$question_reputation.val()==""
      addDomError($question_reputation)
      $reputation_tips.text("请输入正确的数值")
      isSubmit = false
    if parseInt($question_reputation.val()) > user_accout.reputation
      addDomError($question_reputation)
      needReputation = parseInt($question_reputation.val(),10) - user_accout.reputation
      $reputation_tips.text("缺少"+needReputation+"积分").fadeIn()
      isSubmit = false
    return isSubmit unless isSubmit
    $('#new_question').bind('ajax:success', (xhr, data, status)->
      location.href = "/questions/#{data.id}"
    )
    $('#new_question').bind('ajax:error',(xhr,textStatus, errorThrown)->
      alert '我错了'
    )

  #bind event
  $("#question_title").bind "keyup",()->
    $titleCount = $("#titleCount")
    numCountDown($(this),$titleCount,70)
    if $(this).val()
      removeDomError($titleCount)

  $('#addedRule').bind 'change',->
    if $('#additional_rule').css('display') is 'none'
      $('#additional_rule').slideDown(200)
    else
      $('#additional_rule').slideUp(300)

  $("#into_recharge").bind "click",->
    getUserCredit ->
      if(parseInt($('#select_credit').val(),10) > user_accout.credit)
        $('#dialog_payment').append($loadingImg)
        user_accout.needCredit = parseInt($('#select_credit').val(),10) - user_accout.credit
        $.ajax
          url:      "/recharge/generate_order"
          type:     "POST"
          dataType: "json"
          data:     {credit: user_accout.needCredit}
          success:  (data, textStatus, xhr) ->
            $("#order_number").html data.order_id
            $("#order_credit").text "您要支付的金额为："+user_accout.needCredit+"元"
            $("#alipay_form").html data.html
          complete: (xhr, textStatus)->
            $loadingImg.remove()
        $('#dialog_payment').dialog(question_paymentDlg)
        $('#dialog_payment').dialog('open')
      else
        $("#recharge").fadeOut()
        $("#currentUserAccount").text("您当前金额为#{user_accout.credit}元")
        removeDomError($("#credit_tips"))
)

numCountDown = (input,num,len)->
  input = input.val()
  [numDiv,length,inputCount] = [num,len,input.length]
  if input
    inputCount = length - inputCount
    if inputCount < 0
      numDiv.addClass('negative')
    numDiv.text inputCount
  else
    numDiv.text length

#ajax to get the accout credit 
getUserCredit = (callback)->
  $.get "/cash", (data, textStatus, xhr) ->
    user_accout.credit = data.credit
    user_accout.reputation = data.reputation
    callback() if callback
    
# add error style
addDomError = (div...)->
  el.addClass("error").closest('.clearfix').addClass('error') for el in div
removeDomError = (div...)->
  el.removeClass("error").closest('.clearfix').removeClass('error') for el in div
  