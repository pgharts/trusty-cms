import { Plugin, toWidget } from 'ckeditor5';

export default class AssetTagBuilder extends Plugin {
    init() {
        console.log( 'AssetTagBuilder plugin initialized' );
        // Plugin logic goes here
        this._defineSchema();
        this._defineConverters();
        this._defineDataNormalization();
    }

    _defineSchema() {
        const schema = this.editor.model.schema;
        
        schema.register( 'assetImage', {
            allowWhere: '$text',
            isInline: true,
            isObject: true,
            allowAttributes: [ 'id', 'size', 'alt', 'height', 'width' ]
        } );
    }

    _defineConverters() {
        const conversion = this.editor.conversion;
        
        const upcast = conversion.for( 'upcast' );
        const dataDowncast = conversion.for( 'dataDowncast' );
        const editingDowncast = conversion.for( 'editingDowncast' );

        upcast.elementToElement( {
            view: {
                name: 'r:asset:image'
            },
            model: ( viewElement, { writer } ) => {
                const attrs = {};
                const id = viewElement.getAttribute( 'id' );
                const size = viewElement.getAttribute( 'size' );
                const alt = viewElement.getAttribute( 'alt' );
                const height = viewElement.getAttribute( 'height' );
                const width = viewElement.getAttribute( 'width' );

                if ( id ) attrs.id = id;
                if ( size ) attrs.size = size;
                if ( alt ) attrs.alt = alt;
                if ( height ) attrs.height = height;
                if ( width ) attrs.width = width;

                return writer.createElement( 'assetImage', attrs );
            }
        } );

        // Data downcast: ensure no inner whitespace like &nbsp; gets serialized.
        dataDowncast.elementToElement( {
            model: 'assetImage',
            view: ( modelElement, { writer } ) => {
                const attrs = {};
                const id = modelElement.getAttribute( 'id' );
                const size = modelElement.getAttribute( 'size' );
                const alt = modelElement.getAttribute( 'alt' );
                const height = modelElement.getAttribute( 'height' );
                const width = modelElement.getAttribute( 'width' );

                if ( id ) attrs.id = id;
                if ( size ) attrs.size = size;
                if ( alt ) attrs.alt = alt;
                if ( height ) attrs.height = height;
                if ( width ) attrs.width = width;

                return writer.createContainerElement( 'r:asset:image', attrs );
            }
        } );

        // Editing downcast: keep a container element for proper cursor behavior.
        editingDowncast.elementToElement( {
            model: 'assetImage',
            view: ( modelElement, { writer } ) => {
                const attrs = {};
                const id = modelElement.getAttribute( 'id' );
                const size = modelElement.getAttribute( 'size' );
                const alt = modelElement.getAttribute( 'alt' );
                const height = modelElement.getAttribute( 'height' );
                const width = modelElement.getAttribute( 'width' );

                if ( id ) attrs.id = id;
                if ( size ) attrs.size = size;
                if ( alt ) attrs.alt = alt;
                if ( height ) attrs.height = height;
                if ( width ) attrs.width = width;

                return writer.createContainerElement( 'span', attrs );
            }            
        } );       

    }

      _defineDataNormalization() {
        const editor = this.editor;
        const processor = editor.data.processor;

        const originalToView = processor.toView.bind( processor );
        const originalToData = processor.toData.bind( processor );

        // 1) Incoming: <r:asset:image ... /> -> <r:asset:image ...></r:asset:image>
       processor.toView = (data) => {
            let normalized = data;

            // 1) Self-closing -> paired
            normalized = normalized.replace(
                /<r:asset:image\b([^>]*?)\/>/gi,
                '<r:asset:image$1></r:asset:image>'
            );

            // 2) Bare open tag (rare, but happens) -> paired
            normalized = normalized.replace(
                /<r:asset:image\b([^>]*?)>(?!\s*<\/r:asset:image>)/gi,
                '<r:asset:image$1></r:asset:image>'
            );

            return originalToView(normalized);
            };


        processor.toData = (viewFragment) => {
            const html = originalToData(viewFragment);

            return html.replace(
                /<r:asset:image\b([^>]*?)>([\s\S]*?)<\/r:asset:image>/gi,
                (match, attrs, inner) => {
                const cleanedInner = inner.replace(
                    /^(?:\s|&nbsp;|&#160;)+|(?:\s|&nbsp;|&#160;)+$/g,
                    ''
                );
                return `<r:asset:image${attrs} />${cleanedInner}`;
                }
            );
        };
    }
}
