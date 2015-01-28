CKEDITOR.editorConfig = function( config ) {
  config.allowedContent = true;
  config.removeFormatTags = "";
  config.protectedSource.push(/<r:([\S]+).*<\/r:\1>/g);
  config.protectedSource.push(/<r:[^>\/]*\/>/g);

  config.forcePasteAsPlainText = true;
  // if you want to remove clipboard, you have to remove all of these:
  // clipboard, pastetext, pastefromword
  config.removePlugins = "save, newpage, preview, print, templates, forms, flash, smiley, language, pagebreak, iframe, bidi";

  var startupMode = $.cookie('ckeditor.startupMode');
  if (startupMode == 'source' || startupMode == 'wysiwyg' ) {
    config.startupMode = startupMode;
  }

  this.on('mode', function(){
    $.cookie('ckeditor.startupMode', this.mode);
  })

};
