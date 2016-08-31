$(document).ready(function() {
  // Return a helper with preserved width of cells
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };


  $('#pages tbody').sortable({
    helper: fixHelper,
    placeholder: "ui-state-highlight",
    update: function(event, ui) {
      var data = $(this).serialize();

      $.ajax({
        data: data,
        type: 'POST',
        url: 'pages/save-table-position'
      })
    }
  }).disableSelection();
});
