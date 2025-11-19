import { Plugin } from 'ckeditor5';

export default class AssetTagBuilder extends Plugin {
    init() {
        console.log( 'AssetTagBuilder plugin initialized' );
        // Plugin logic goes here
        this._defineSchema();
        this._defineConverters();
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

                return writer.createEmptyElement( 'r:asset:image', attrs );
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

                return writer.createContainerElement( 'r:asset:image', attrs );
            }
        } );
    }
}
