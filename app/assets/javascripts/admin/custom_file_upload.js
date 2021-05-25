$(function () {
  var fileUpload = $('#asset_asset');
  var fileChosen = $('#file-chosen');
  fileUpload.on('change', function() {
    fileChosen.text(this.files[0].name)
  })
});
