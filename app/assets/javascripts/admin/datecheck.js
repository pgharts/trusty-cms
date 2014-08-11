$(function() {
  if (!Modernizr.inputtypes['date']) {
    $('input[type=date]').datepicker({
      dateFormat: 'mm/dd/yyyy'
    });
  }
});
