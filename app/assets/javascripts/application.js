// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require on_the_spot
//= require_tree .
$(function(){
  $.ajaxSetup({
    beforeSend: function( xhr ) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });
})
function showAjaxError(a,d){
  var e=$('<div class="error-notification supernovabg"><h3>'+d+"</h3>(点击此区域消除显示)</div>");
  var c=function(){
    $(".error-notification").fadeOut("fast",function(){
      $(this).remove()
      })
    };
    e.click(function(f){
      c()
    });
    a.append(e);
    e.fadeIn("fast");
    setTimeout(c,4000)
}
function checkNum(str){
  return(/^\d+$/.test(str))
}
