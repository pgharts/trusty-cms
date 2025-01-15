(function(Dropdown, $) {
  Dropdown.setup = function(link) {
    var menu = Dropdown.findMenu(link);

    // Attach click handler to toggle dropdown
    $(link).off('click').on('click', function(event) {
      event.preventDefault();
      event.stopPropagation(); // Prevent click from propagating to document
      var $link = $(this);
      var $menuWrapper = $link.siblings("div.dropdown_wrapper");

      if ($menuWrapper.is(':visible')) {
        // If already visible, hide it
        $menuWrapper.css('z-index', '').slideUp();
        $link.removeClass('selected');
      } else {
        // Close other dropdowns
        $('.dropdown_wrapper').css('z-index', '').slideUp();
        $('a.dropdown').removeClass('selected');

        // Show the current dropdown with priority z-index
        $menuWrapper.css('z-index', '1000').slideDown();
        $link.addClass('selected');
      }
    });
  };

  Dropdown.findMenu = function(link) {
    var match = $(link).attr('href').match(/#(.+)$/)[1];
    return $('#' + match);
  };

  // Close dropdown when clicking anywhere else
  $(document).on('click', function(event) {
    if (!$(event.target).closest('.dropdown_wrapper, a.dropdown').length) {
      $('.dropdown_wrapper').css('z-index', '').slideUp();
      $('a.dropdown').removeClass('selected');
    }
  });

}(window.Dropdown = window.Dropdown || {}, jQuery));

$(function () {
  $('a.dropdown').each(function() {
    Dropdown.setup(this);
  });
});
