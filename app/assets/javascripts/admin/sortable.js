$(document).ready(function() {
  // Return a helper with preserved width of cells
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };


  $('#pages tbody').sortable({
    beforeStop: function(event,ui) {
      table_rows = ui.item.nextAll('tr');
      for(i=0;i<table_rows.length;i++) {
        var parent_id = table_rows.eq(i).attr('id');
        if (parent_id != undefined) {
          parent_id = parent_id.replace('page_','');
          var this_id = ui.item.attr('data-tt-parent-id');
          if(this_id == parent_id) {
            $(this).sortable('cancel');
          }
        }
      }
    },
    helper: fixHelper,
    placeholder: "ui-state-highlight",
    cancel: ".expanded",
    update: function(event, ui) {
      table_rows = $(this).children();
      var data = [];
      for(i=0;i<table_rows.length;i++) {
        var this_id = table_rows.eq(i).attr('id').replace("page_", "");
        var position = i;
        // var parent_id = table_rows.eq(i).attr('data-tt-parent-id');
        data.push(this_id, position)
      }
      data.splice(0,2);
      console.log(data);
      $.ajax({
        data: {new_position: data},
        type: 'POST',
        url: 'save-table-position'
      })
    }
  }).disableSelection();
});
