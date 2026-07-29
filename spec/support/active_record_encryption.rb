# The app configures ActiveRecord::Encryption from ENV vars (see
# config/initializers/active_record_encryption.rb), which are unset in the test
# environment. Without keys, writing an encrypted attribute (e.g. User#otp_secret
# from devise-two-factor) raises a Configuration error. Configure deterministic
# test keys here so specs can exercise encrypted attributes.
ActiveRecord::Encryption.configure(
  primary_key: 'test_primary_key_for_specs_only_0001',
  deterministic_key: 'test_deterministic_key_for_specs_0001',
  key_derivation_salt: 'test_key_derivation_salt_for_specs_0001'
)
