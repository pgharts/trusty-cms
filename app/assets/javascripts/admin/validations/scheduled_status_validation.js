$(document).ready(function() {
  function validateDateTime() {
    const publishedAt = $('#page_published_at').val();
    const status = $('#page_status_id').val();
    const publishedTime = new Date(publishedAt);
    const currentTime = new Date();

    if (status == 90) {
      if (publishedTime == 'Invalid Date') {
        $('#published_at_error').text('Select a valid Date & Time.');
        $('.error').show();
        return false;
      }
      if (publishedTime < currentTime) {
        $('#published_at_error').text('Scheduled Date & Time cannot be in the past.');
        $('.error').show();
        return false;
      }
    }

    if (status == 100) {
      if (publishedTime > currentTime) {
        $('#published_at_error').text('Invalid Date & Time: Use a current or past Publish Date & Time, or set Status to Scheduled.');
        $('.error').show();
        return false;
      }
    }

    $('.error').hide();
    return true;
  }

  $('#save-button, #save-and-continue-button').on('click', function(event) {
    if (!validateDateTime()) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  });
});
