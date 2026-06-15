import { Plugin, Widget, toWidget } from 'ckeditor5';

export default class AssetLinkTagBuilder extends Plugin {
    static get requires() {
        return [ Widget ];
    }

    init() {
        this._defineSchema();
        this._defineConverters();
        this._defineDataNormalization();
    }

    _defineSchema() {
        const schema = this.editor.model.schema;

        schema.register( 'assetLink', {
            allowWhere: '$text',
            isInline: true,
            isObject: true,
            allowAttributes: [ 'id', 'size', 'text', 'anchor', 'class' ]
        } );
    }

    _defineConverters() {
        const conversion = this.editor.conversion;
        const upcast = conversion.for( 'upcast' );
        const dataDowncast = conversion.for( 'dataDowncast' );
        const editingDowncast = conversion.for( 'editingDowncast' );

        upcast.elementToElement( {
            view: {
                name: 'r:asset:link'
            },
            model: ( viewElement, { writer } ) => {
                const attrs = {};
                const id = viewElement.getAttribute( 'id' );
                const size = viewElement.getAttribute( 'size' );
                const text = viewElement.getAttribute( 'text' );
                const anchor = viewElement.getAttribute( 'anchor' );
                const klass = viewElement.getAttribute( 'class' );

                if ( id ) attrs.id = id;
                if ( size ) attrs.size = size;
                if ( text ) attrs.text = text;
                if ( anchor ) attrs.anchor = anchor;
                if ( klass ) attrs.class = klass;

                return writer.createElement( 'assetLink', attrs );
            }
        } );

        dataDowncast.elementToElement( {
            model: 'assetLink',
            view: ( modelElement, { writer } ) => {
                const attrs = {};
                const id = modelElement.getAttribute( 'id' );
                const size = modelElement.getAttribute( 'size' );
                const text = modelElement.getAttribute( 'text' );
                const anchor = modelElement.getAttribute( 'anchor' );
                const klass = modelElement.getAttribute( 'class' );

                if ( id ) attrs.id = id;
                if ( size ) attrs.size = size;
                if ( text ) attrs.text = text;
                if ( anchor ) attrs.anchor = anchor;
                if ( klass ) attrs.class = klass;

                return writer.createContainerElement( 'r:asset:link', attrs );
            }
        } );

        editingDowncast.elementToElement( {
            model: 'assetLink',
            view: ( modelElement, { writer } ) => {
                const id = modelElement.getAttribute( 'id' );
                const size = modelElement.getAttribute( 'size' );
                const text = modelElement.getAttribute( 'text' );

                const container = writer.createContainerElement( 'span', {
                    class: 'asset-link-tag',
                    'data-asset-id': id,
                    'data-asset-size': size
                } );

                const label = writer.createUIElement(
                    'span',
                    { class: 'asset-link-tag__label' },
                    function ( domDocument ) {
                        const domEl = this.toDomElement( domDocument );
                        const parts = [
                            'Asset link',
                            id ? `#${id}` : '',
                            size ? `(${size})` : '',
                            text ? `— ${text}` : ''
                        ].filter( Boolean );

                        domEl.textContent = parts.join( ' ' );
                        return domEl;
                    }
                );

                writer.insert( writer.createPositionAt( container, 0 ), label );
                return toWidget( container, writer, { label: `Asset link ${id ? `#${id}` : ''}` } );
            }
        } );
    }

    _defineDataNormalization() {
        const editor = this.editor;
        const processor = editor.data.processor;

        const originalToView = processor.toView.bind( processor );
        const originalToData = processor.toData.bind( processor );

        processor.toView = ( data ) => {
            let normalized = data;

            normalized = normalized.replace(
                /<r:asset:link\b([^>]*?)\/>/gi,
                '<r:asset:link$1></r:asset:link>'
            );

            normalized = normalized.replace(
                /<r:asset:link\b([^>]*?)>(?!\s*<\/r:asset:link>)/gi,
                '<r:asset:link$1></r:asset:link>'
            );

            return originalToView( normalized );
        };

        processor.toData = ( viewFragment ) => {
            const html = originalToData( viewFragment );

            return html.replace(
                /<r:asset:link\b([^>]*?)>([\s\S]*?)<\/r:asset:link>/gi,
                ( match, attrs, inner ) => {
                    const cleanedInner = inner.replace(
                        /^(?:\s|&nbsp;|&#160;)+|(?:\s|&nbsp;|&#160;)+$/g,
                        ''
                    );
                    return `<r:asset:link${attrs} />${cleanedInner}`;
                }
            );
        };
    }
}
