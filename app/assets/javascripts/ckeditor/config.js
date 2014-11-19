CKEDITOR.editorConfig = function( config ) {
  config.allowedContent = true;
  config.removeFormatTags = "";
  config.protectedSource.push(/<r:([\S]+)*>.*<\/r:\1>/g);
  config.protectedSource.push(/<r:[^>\/]*\/>/g);
  config.forcePasteAsPlainText = true;
  config.removePlugins = "save, clipboard, pastetext, pastefromword, newpage, preview, print, templates, forms, flash, smiley, language, pagebreak, iframe, bidi";
};
