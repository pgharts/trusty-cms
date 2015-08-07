(function(PageEdit, $) {
  PageEdit.addPart = function (form) {
    if (PageEdit.validPartName()) {
      PageEdit.partLoading();
      $.post(
        $(form).attr('action'),
        $(form).serialize(),
        function(data) {
          $('#tab_control .pages').append(data);
          PageEdit.partAdded();
        }
      )
    }
  };

  PageEdit.partAdded = function (tabId) {
    $('#add_part_busy').hide();
    $('#add_part_button').attr('disabled', false);
    Popup.close();
    $('#part_name_field').val('');
    TabControl.updateTabsBasedOnPages();
    TabControl.selectTab($('div#tab_control .tabs .tab').last().attr('id'));
  };

  PageEdit.partLoading = function () {
    $('#add_part_button').attr('disabled', true);
    $('#add_part_busy').show();
  };

  PageEdit.validPartName = function () {
    var partNameField = $('#part_name_field');
    var name = partNameField.val().toLowerCase();
    if (name === '') {
      alert('Part name cannot be empty.');
      return false;
    }
    if ($('#tab_' + name).length > 0) {
      alert('Part name must be unique.');
      return false;
    }
    return true;
  }

}(window.PageEdit = window.PageEdit || {}, jQuery));

$(function () {
  $('#new_page_part').submit(function(event) {
    event.preventDefault();
    PageEdit.addPart(this);
  });
});
