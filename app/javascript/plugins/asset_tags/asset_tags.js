import AssetTagBuilder from './asset_tag_builder';
import { Plugin } from 'ckeditor5';

export default class AssetTags extends Plugin {
  static get requires() {
    return [ AssetTagBuilder ];
  }
}