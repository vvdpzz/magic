var htmlEscape = function(txt) {
  return txt.replace(/&/g,'&amp;').                                         
  replace(/>/g,'&gt;').                                           
  replace(/</g,'&lt;').                                           
  replace(/"/g,'&quot;')              
}

var stringutil = {
  cut: function(text, maxLength) {
    if (text.length < maxLength)
    return text;
    else
    return text.slice(0, maxLength - 3) + '...';
  }
}

var dateFormat = function(date) {
  return date.getFullYear()+'-'+(date.getMonth()+1)+'-'+date.getDate()+' '+date.getHours()+':'+date.getMinutes()+':'+date.getSeconds();
}