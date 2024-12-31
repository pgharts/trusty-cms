$(document).ready(function() {
  function isValidDateTime(value) {
    return !isNaN(new Date(value).getTime());
  }

  function showError(message) {
    $('#published-at-error').text(message);
    $('.error').removeClass('hidden');
  }

  function hideError() {
    $('.error').addClass('hidden');
  }

  function validateScheduledStatus(publishedTime, currentTime) {
    if (!isValidDateTime(publishedTime)) {
      showError('Select a valid Date & Time.');
      return false;
    }
    if (publishedTime < currentTime) {
      showError('Scheduled Date & Time cannot be in the past.');
      return false;
    }

    hideError();
    return true;
  }

  function validatePublishedStatus(publishedTime, currentTime) {
    if (publishedTime > currentTime) {
      showError('Published Date & Time cannot be in the future. Clear the date and time to publish now, or set the status to Scheduled.');
      return false;
    }

    hideError();
    return true;
  }

  function validateDateTime() {
    const publishedAt = $('#page_published_at').val();
    const status = $('#page_status_id').val();
    const publishedTime = new Date(publishedAt);
    const currentTime = new Date();

    if (status === '90') {
      return validateScheduledStatus(publishedTime, currentTime);
    }

    if (status === '100') {
      return validatePublishedStatus(publishedTime, currentTime);
    }
  }

  $('#save-button, #save-and-continue-button').on('click', function(event) {
    if (!validateDateTime()) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  });
});
