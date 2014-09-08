(function(Dropdown, $) {
  Dropdown.setup = function(link) {
    var menuToWrap = Dropdown.findMenu(link);
    if ($(menuToWrap).parent("div").length == 0) {
      menuToWrap.wrap("<div class='dropdown_wrapper' style='position: absolute; display: none'></div>");

      $(link).on('click', function (event) {
        event.preventDefault();
        $(this).toggleClass('selected');
        Dropdown.findMenu(this).closest('.dropdown_wrapper').slideToggle();
      })
    };
  }

  Dropdown.findMenu = function(link) {
    var match = $(link).attr('href').match(/\#(.+)$/)[1];
    return $('#' + match);
  }

}(window.Dropdown = window.Dropdown || {}, jQuery));

$(function () {
  $('a.dropdown').each(function(){
    Dropdown.setup(this);
  });
});
