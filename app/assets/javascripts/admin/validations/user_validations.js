$(function () {
  $(".user_form").validate({

    // Specify the validation rules
    rules: {
      "user[name]": {required: true},
      "user[login]": "required",
      "user[email]": {
        email: true
      },
      "user[password]": {
        required: true,
        minlength: 5
      },
      "user[password_confirmation]": {
        required: true,
        equalTo: "#user_password"
      }
    }
  });
});