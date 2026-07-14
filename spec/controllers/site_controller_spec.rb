require 'spec_helper'

describe SiteController, type: :request do
  let!(:home) { FactoryBot.create(:home, title: 'Home') }

  before { home.parts.create(name: 'body', content: 'Welcome <r:title />') }

  describe 'serving pages' do
    it 'renders the home page at the root path' do
      get '/'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Welcome Home')
    end

    it 'renders a published child page by its path' do
      about = FactoryBot.create(:page, title: 'About', slug: 'about', parent: home, status_id: Status[:published].id)
      about.parts.create(name: 'body', content: 'About <r:title />')

      get '/about'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('About About')
    end

    it 'renders a nested published page' do
      section = FactoryBot.create(:page, title: 'Section', slug: 'section', parent: home, status_id: Status[:published].id)
      article = FactoryBot.create(:page, title: 'Article', slug: 'article', parent: section, status_id: Status[:published].id)
      article.parts.create(name: 'body', content: 'Deep content')

      get '/section/article'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Deep content')
    end
  end

  describe 'unknown paths' do
    it 'renders the not-found template with a 404 status' do
      get '/does/not/exist'
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('could not be located')
    end
  end

  describe 'content type' do
    it 'sets the response Content-Type from the page layout' do
      layout = Layout.create!(name: 'Plain', content: '<r:content />', content_type: 'text/plain')
      page = FactoryBot.create(:page, title: 'Raw', slug: 'raw', parent: home, status_id: Status[:published].id, layout: layout)
      page.parts.create(name: 'body', content: 'plain body')

      get '/raw'
      expect(response.media_type).to eq('text/plain')
    end
  end

  describe '.cache_timeout' do
    it 'round-trips through the response cache director' do
      original = SiteController.cache_timeout
      SiteController.cache_timeout = 5.minutes
      expect(SiteController.cache_timeout).to eq(5.minutes)
    ensure
      SiteController.cache_timeout = original
    end
  end
end
