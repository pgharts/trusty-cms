# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
TrustyCms::Application.config.secret_token = Rails.env.production? ? ENV['SECRET_TOKEN'] : 'this-should-never-be-used-in-production-8d8c51c1afea65da45a7dba520f52536569dd203d5901369001c59259b59393f93a862a869a650b6f58214f8204ac0693a61e93b4c0a349827d4c36320f336a1'
