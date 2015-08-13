# Commonly occurring user actions in tests.

# This takes a username and by default assumes the password is 'password'.
def log_in_as(login, plaintext_password = 'password')
  visit '/'
  fill_in 'username_or_email', with: login
  fill_in 'password', with: plaintext_password
  click_on 'Login'
end

