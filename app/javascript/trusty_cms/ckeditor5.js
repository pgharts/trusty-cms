/**
 * This configuration was generated using the CKEditor 5 Builder. You can modify it anytime using this link:
 * https://ckeditor.com/ckeditor-5/builder/#installation/NoJgNARCB0Ds0FYKQByxARgGwNgFlgAYsURMBOPFAZkNmvJBxHxdgQyazz3JT2QQApgDtkhMMAxgJE6fIC6kLOQwAjFUIgKgA===
 */

const defaultStyleDefinitions = [
            {
                name: 'Article category',
                element: 'h3',
                classes: ['category']
            },
            {
                name: 'Title',
                element: 'h2',
                classes: ['document-title']
            },
            {
                name: 'Subtitle',
                element: 'h3',
                classes: ['document-subtitle']
            },
            {
                name: 'Info box',
                element: 'p',
                classes: ['info-box']
            },
            {
                name: 'CTA Link Primary',
                element: 'a',
                classes: ['button', 'button--green']
            },
            {
                name: 'CTA Link Secondary',
                element: 'a',
                classes: ['button', 'button--black']
            },
            {
                name: 'Marker',
                element: 'span',
                classes: ['marker']
            },
            {
                name: 'Spoiler',
                element: 'span',
                classes: ['spoiler']
            }
        ]

import {
    ClassicEditor,
    Alignment,
    Autoformat,
    AutoImage,
    AutoLink,
    Autosave,
    BlockQuote,
    Bold,
    Bookmark,
    Code,
    Essentials,
    FindAndReplace,
    FontBackgroundColor,
    FontColor,
    FontFamily,
    FontSize,
    FullPage,
    Fullscreen,
    GeneralHtmlSupport,
    Heading,
    Highlight,
    HorizontalLine,
    HtmlComment,
    HtmlEmbed,
    ImageBlock,
    ImageCaption,
    ImageEditing,
    ImageInline,
    ImageInsert,
    ImageInsertViaUrl,
    ImageResize,
    ImageStyle,
    ImageTextAlternative,
    ImageToolbar,
    ImageUpload,
    ImageUtils,
    Indent,
    IndentBlock,
    Italic,
    Link,
    LinkImage,
    List,
    ListProperties,
    Paragraph,
    PasteFromOffice,
    RemoveFormat,
    ShowBlocks,
    SimpleUploadAdapter,
    SourceEditing,
    SpecialCharacters,
    SpecialCharactersArrows,
    SpecialCharactersCurrency,
    SpecialCharactersEssentials,
    SpecialCharactersLatin,
    SpecialCharactersMathematical,
    SpecialCharactersText,
    Strikethrough,
    Style,
    Subscript,
    Superscript,
    Table,
    TableCaption,
    TableCellProperties,
    TableColumnResize,
    TableLayout,
    TableProperties,
    TableToolbar,
    TextTransformation,
    TodoList,
    Underline
} from 'ckeditor5';

import "ckeditor5/ckeditor5.css";

const editorConfig = {
    toolbar: {
        items: [
            'undo',
            'redo',
            '|',
            'sourceEditing',
            'showBlocks',
            'findAndReplace',
            'fullscreen',
            '|',
            'heading',
            'style',
            '|',
            'fontSize',
            'fontFamily',
            'fontColor',
            'fontBackgroundColor',
            '|',
            'bold',
            'italic',
            'underline',
            'strikethrough',
            'subscript',
            'superscript',
            'code',
            'removeFormat',
            '|',
            'specialCharacters',
            'horizontalLine',
            'link',
            'bookmark',
            'insertImage',
            'insertImageViaUrl',
            'insertTable',
            'insertTableLayout',
            'highlight',
            'blockQuote',
            'htmlEmbed',
            '|',
            'alignment',
            '|',
            'bulletedList',
            'numberedList',
            'todoList',
            'outdent',
            'indent'
        ],
        shouldNotGroupWhenFull: false
    },
    plugins: [
        Alignment,
        Autoformat,
        AutoImage,
        AutoLink,
        Autosave,
        BlockQuote,
        Bold,
        Bookmark,
        Code,
        Essentials,
        FindAndReplace,
        FontBackgroundColor,
        FontColor,
        FontFamily,
        FontSize,
        FullPage,
        Fullscreen,
        GeneralHtmlSupport,
        Heading,
        Highlight,
        HorizontalLine,
        HtmlComment,
        HtmlEmbed,
        ImageBlock,
        ImageCaption,
        ImageEditing,
        ImageInline,
        ImageInsert,
        ImageInsertViaUrl,
        ImageResize,
        ImageStyle,
        ImageTextAlternative,
        ImageToolbar,
        ImageUpload,
        ImageUtils,
        Indent,
        IndentBlock,
        Italic,
        Link,
        LinkImage,
        List,
        ListProperties,
        Paragraph,
        PasteFromOffice,
        RemoveFormat,
        ShowBlocks,
        SimpleUploadAdapter,
        SourceEditing,
        SpecialCharacters,
        SpecialCharactersArrows,
        SpecialCharactersCurrency,
        SpecialCharactersEssentials,
        SpecialCharactersLatin,
        SpecialCharactersMathematical,
        SpecialCharactersText,
        Strikethrough,
        Style,
        Subscript,
        Superscript,
        Table,
        TableCaption,
        TableCellProperties,
        TableColumnResize,
        TableLayout,
        TableProperties,
        TableToolbar,
        TextTransformation,
        TodoList,
        Underline
    ],
    fontFamily: {
        supportAllValues: true
    },
    fontSize: {
        options: [10, 12, 14, 'default', 18, 20, 22],
        supportAllValues: true
    },
    fullscreen: {
        onEnterCallback: container =>
            container.classList.add(
                'editor-container',
                'editor-container_classic-editor',
                'editor-container_include-style',
                'editor-container_include-fullscreen',
                'main-container'
            )
    },
    heading: {
        options: [
            {
                model: 'paragraph',
                title: 'Paragraph',
                class: 'ck-heading_paragraph'
            },
            {
                model: 'heading1',
                view: 'h1',
                title: 'Heading 1',
                class: 'ck-heading_heading1'
            },
            {
                model: 'heading2',
                view: 'h2',
                title: 'Heading 2',
                class: 'ck-heading_heading2'
            },
            {
                model: 'heading3',
                view: 'h3',
                title: 'Heading 3',
                class: 'ck-heading_heading3'
            },
            {
                model: 'heading4',
                view: 'h4',
                title: 'Heading 4',
                class: 'ck-heading_heading4'
            },
            {
                model: 'heading5',
                view: 'h5',
                title: 'Heading 5',
                class: 'ck-heading_heading5'
            },
            {
                model: 'heading6',
                view: 'h6',
                title: 'Heading 6',
                class: 'ck-heading_heading6'
            }
        ]
    },
    htmlSupport: {
        allow: [
            {
                name: /^.*$/,
                styles: true,
                attributes: true,
                classes: true
            }
        ]
    },
    image: {
        toolbar: [
            'toggleImageCaption',
            'imageTextAlternative',
            '|',
            'imageStyle:inline',
            'imageStyle:wrapText',
            'imageStyle:breakText',
            '|',
            'resizeImage'
        ]
    },

    licenseKey: 'GPL',
    link: {
        addTargetToExternalLinks: true,
        defaultProtocol: 'https://',
        decorators: {
            toggleDownloadable: {
                mode: 'manual',
                label: 'Downloadable',
                attributes: {
                    download: 'file'
                }
            }
        }
    },
    list: {
        properties: {
            styles: true,
            startIndex: true,
            reversed: true
        }
    },
    menuBar: {
        isVisible: true
    },
    placeholder: 'Type or paste your content here!',
    style: {
       definitions: 
         window.TRUSTY_CMS_EDITOR?.styleDefinitions?.length
        ? window.TRUSTY_CMS_EDITOR.styleDefinitions
        : defaultStyleDefinitions,
    },
    table: {
        contentToolbar: ['tableColumn', 'tableRow', 'mergeTableCells', 'tableProperties', 'tableCellProperties']
    },
    simpleUpload: {
        uploadUrl: '/admin/assets/uploader',
        headers: {
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    }
};

ClassicEditor
    .create(document.querySelector('#editor'), editorConfig)
    .then(editor => {
        const pagePart = document.querySelector('#editor').getAttribute('data-part');
        const hiddenInput = document.querySelector(`#part_${pagePart}_content`);

        editor.model.document.on('change:data', () => {
            hiddenInput.value = editor.getData();
        })
    }).catch(error => {
        console.error(error);
    });
