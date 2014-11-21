PageFields = {
  attachEvents: function() {

    $('#add_page_field_button').click(function(e){
      e.preventDefault();
      $.ajax({
        method: 'post',
        url: '/admin/page_fields/',
        data: $('#new_page_field').serialize(),
        success: function(data, textStatus, jqXHR) {
          PageFields.updateFields(data);
        }
      });
    });

    $('.remove_field').click(function(e){
      e.preventDefault();
      var row = $(this).closest('tr');
      row.find(".delete_input").val(true);
      row.find(".page_field_name").val('');
      row.hide();
    });

  },
  updateFields: function(element) {
    $('.fieldset tr:last').after(element);
    Popup.close();
    $('#new_page_field').trigger('reset');
    PageFields.attachEvents();
  }
};

$(function() {
  PageFields.attachEvents();
});