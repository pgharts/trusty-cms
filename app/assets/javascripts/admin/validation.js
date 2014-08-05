function validateForm(selector) {
  $(selector).validate();
}

$(function () {
  validateForm('form');
});