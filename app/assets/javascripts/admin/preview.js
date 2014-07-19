(function(Preview, $) {
  Preview.showPreview = function(form){
    var oldTarget = form.target;
    var oldAction = form.action;

    var $previewer = $('#preview_panel');
    var $preview_tools = $previewer.find('.preview_tools');
    var $frame = $('#page-preview');

    $(window).scrollTop(0);
    $previewer.show();
    $preview_tools.css('opacity', 1);
    $('body').addClass('clipped');
    form.target = $frame.attr('id');
    form.action = relative_url_root + '/admin/preview';
    form.submit();

    form.target = oldTarget;
    form.action = oldAction;
  }

}(window.Preview = window.Preview || {}, jQuery));

$(function () {
  $('#show-preview').on('click', function(event){
    event.preventDefault();
    Preview.showPreview(this.form);
  });

  $('.preview_tools a.cancel').on('click', function(event){
    event.preventDefault();
    $('#preview_panel').hide();
    $('body').removeClass('clipped');
    $('#page-preview').attr('src', '');
  });

  $('iframe').on('load', function(event){
    $('#preview_panel .preview_tools').css('opacity', null);
  });
});
