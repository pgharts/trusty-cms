$(document).ready(function() {

  var radModal;

  function centeredPopup(url,w,h){
    var popupWindow = null;
    LeftPosition = (screen.width) ? (screen.width-w)/2 : 0;
    TopPosition = (screen.height) ? (screen.height-h)/2 : 0;
    settings =
    'height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition;
    popupWindow = window.open(url,"Share",settings);
  }

  $(".rad-window-close").click(function(event) {
    event.preventDefault();
   $("#rad-social-email-form").fadeToggle('slow');
  });

  $(".rad-popup-window").click(function(event){
    event.preventDefault();
    var url = $(this).attr("href");
    centeredPopup(url, 625, 430)

  });

  var form = $("#rad-social-email-form");

  validator = form.validate({
      submitHandler: function(form) {
        var button = $('#rad_email_submit');
        button.attr('disabled', true);
        button.removeClass('primary-button').addClass('disabled-button');
        form.submit();
        clear_form();
      }
  });


  var radEmailValidator = new RadEmailValidator(form);
  radEmailValidator.addRules();

  form.find('#rad_email_submit').click(function(e) {
      return new RadAjaxForm(form).submit(OnSuccess, OnError, OnComplete);
  });

  function OnSuccess(data) {
    $("#rad-social-email-form").addClass('hidden');
    $("#rad-confirmation").removeClass('hidden');

  }

  function OnError(xhr) {
      processFailure(xhr);
  }

  function OnComplete() {
      //$('#express_contact_form').find('.continue').attr('disabled', false);
      //$('#express_contact_form').find(".loader").removeClass('ajax-loader');
  }

  function clear_form(){
    $('#rs-from').val('');
    $('#rs-from_name').val('');
    $('#rs-to').val('');
    $('#rs-message').val($('#rs-base-message').val());
    var captcha = new Captcha("#recaptcha-container");
    captcha.reload();
  }

function processFailure(xhr)
{
    var captcha = new Captcha("#recaptcha-container");
    var error_msg = xhr.getResponseHeader("ErrorMsg");
    displayErrorMessage(error_msg);
    captcha.reload();
}

function displayErrorMessage(msg) {
    var error_msg_div = $('.rad-email-error');
    error_msg_div.text(msg);
    error_msg_div.show();
}


});