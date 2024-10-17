$(function () {
    const fileUpload = $('#asset_asset');
    const fileChosen = $('#file-chosen');
    fileUpload.on('change', function () {
        fileChosen.text(this.files[0].name)
    })
});
