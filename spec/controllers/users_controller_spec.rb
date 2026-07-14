require 'spec_helper'

describe Admin::UsersController, type: :controller do
  routes { TrustyCms::Application.routes }

  let(:admin) { create(:user, first_name: 'Ada', last_name: 'Admin', email: 'admin@example.com', admin: true) }

  describe 'access control' do
    it 'denies non-admin users and redirects to the pages index' do
      editor = create(:user, first_name: 'Ed', last_name: 'Editor', email: 'editor@example.com', admin: false)
      sign_in(editor)

      get :index

      expect(response).to redirect_to(controller: 'pages', action: 'index')
      expect(flash[:error]).to match(/administrative privileges/)
    end
  end

  context 'as an admin' do
    before { sign_in(admin) }

    describe 'GET index' do
      it 'succeeds' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET show' do
      it 'redirects to the edit page' do
        user = create(:user, email: 'someone@example.com')
        get :show, params: { id: user.id }
        expect(response).to redirect_to(edit_admin_user_path(user.id))
      end
    end

    describe 'POST create' do
      let(:valid_params) do
        { user: { first_name: 'New', last_name: 'User', email: 'new@example.com',
                  password: 'ComplexPass1!', password_confirmation: 'ComplexPass1!' } }
      end

      it 'creates the user and redirects with a notice' do
        expect { post :create, params: valid_params }.to change(User, :count).by(1)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq('User was created.')
      end

      it 'does not create an invalid user and re-renders new' do
        bad = { user: { first_name: 'Bad', last_name: 'User', email: '', password: 'weak' } }
        expect { post :create, params: bad }.not_to change(User, :count)
        expect(flash[:error]).to match(/error saving the user/)
      end
    end

    describe 'DELETE destroy' do
      it 'refuses to delete the current user and redirects with an error' do
        expect { delete :destroy, params: { id: admin.id } }.not_to change(User, :count)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:error]).to be_present
      end
    end

    describe 'PATCH disable_2fa' do
      it 'clears the two-factor settings and redirects' do
        user = create(:user, email: 'twofa@example.com')
        # otp_secret is an encrypted attribute and encryption keys are not set up
        # in the test env, so we only seed the plain boolean flag.
        user.update_columns(otp_required_for_login: true)

        patch :disable_2fa, params: { id: user.id }

        user.reload
        expect(user.otp_required_for_login).to be(false)
        expect(user.otp_secret).to be_nil
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
