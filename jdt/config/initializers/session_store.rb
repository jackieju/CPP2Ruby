# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_jdt_session',
  :secret      => '2507ec416daf19d12550f6258432ee236c3d266108ef28cbea74a2543e86ff067de58aba611635b7b586ba7ca7713fd7db43236e218fa09f5eef725d6788d865'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
