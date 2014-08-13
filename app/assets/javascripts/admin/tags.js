$(function(){
  $('#tag_reference').click(function(event){
    event.preventDefault();
    var href = $(this).attr('href');
    $.ajax({
      url: href,
      type: "GET",
      dataType: "html",
      success: function(url){
          $('#popups').append(url);
      }
    });
  });
});