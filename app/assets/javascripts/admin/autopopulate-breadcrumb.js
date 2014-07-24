(function(AutopopulateBreadcrumb, $) {
  AutopopulateBreadcrumb.oldTitle = '';

  AutopopulateBreadcrumb.setup = function(input) {
    // Don't do this if slug and breadcrumb aren't on this page
    if ($('#page_slug').length > 0 && $('#page_breadcrumb').length > 0) {

      AutopopulateBreadcrumb.oldTitle = $(input).val();

      $(input).on('keyup', function(event) {
        var title = $(this).val();
        var $slug = $('#page_slug');
        var $breadcrumb = $('#page_breadcrumb');

        // If the slug is tracking with the title, keep tracking.
        if (toSlug(AutopopulateBreadcrumb.oldTitle) == $slug.val()) {
          $slug.val(toSlug(title));
        }
        // If the breadcrumb is tracking with the title, keep tracking.
        if (AutopopulateBreadcrumb.oldTitle == $breadcrumb.val()) {
          $breadcrumb.val(title);
        }
        // The current title becomes the old title for next keyup.
        AutopopulateBreadcrumb.oldTitle = title;
      });
    }
  }

}(window.AutopopulateBreadcrumb = window.AutopopulateBreadcrumb || {}, jQuery));

$(function () {
  $('input#page_title').each(function(){
    AutopopulateBreadcrumb.setup(this);
  });
});
