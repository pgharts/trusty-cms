(function(Popup, $) {
  Popup.setup = function(link) {
    $(link).on('click', function(event){
      event.preventDefault();
      var href = $(link).attr('href');
      var match = href.match(/\#(.+)$/);
      Popup.show(match[1]);
    });
  }

  Popup.show = function(popupId) {
    $('#popups').append($('#popup_window .content .popup').detach());
    $('#popup_window .content').append($('#' + popupId).detach());

    var popup_window = $('#popup_window').detach();
    $('body').prepend(popup_window);

    $('#popup_window').show();
    $('#popup_window #' + popupId).show();

    var l = parseInt($(window).scrollLeft() + ($(window).width() - $('#popup_window').width()) / 2) + 'px';
    var t = parseInt($(window).scrollTop() + ($(window).height() - $('#popup_window').height()) / 2.2) + 'px';

    $("#popup_window").css('left', l);
    $("#popup_window").css('top', t);
    $("#popup_window form input[type='text']:first").focus();
  }

  Popup.close = function() {
    $('#popup_window').hide();
    $('div.popup').hide();
  }

}(window.Popup = window.Popup || {}, jQuery));

$(function () {
  $('a.popup').each(function(){
    Popup.setup(this);
  });
});
