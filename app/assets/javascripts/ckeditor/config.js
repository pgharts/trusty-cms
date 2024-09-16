CKEDITOR.editorConfig = function (config) {
    config.allowedContent = true;
    config.removeFormatTags = "";
    config.fillEmptyBlocks = false;
    config.protectedSource.push(/<r:([\S]+).*<\/r:\1>/g);
    config.protectedSource.push(/<r:[^>/]*\/>/g);
    //let paste from word be available
    // config.forcePasteAsPlainText = false;
    // if you want to remove clipboard, you have to remove all of these:
    // clipboard, pastetext, pastefromword
    config.removePlugins = "save, newpage, preview, print, templates, forms, flash, smiley, language, pagebreak, iframe, bidi";

    var startupMode = Cookies.get('ckeditor.startupMode');
    if (startupMode == 'source' || startupMode == 'wysiwyg') {
        config.startupMode = startupMode;
    }

    this.on('mode', function () {
        Cookies.set('ckeditor.startupMode', this.mode);
    })

};
