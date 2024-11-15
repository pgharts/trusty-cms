module Admin::UsersHelper
  def roles(user)
    roles = []
    roles << I18n.t('admin') if user.admin?
    roles << I18n.t('editor') if user.editor?
    roles.join(', ')
  end
end
