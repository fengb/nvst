# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Nvst::Application.config.secret_key_base = ENV['NVST_SECRET'] || 'e86292e73dc926adb449820ee8879a5d921c91c6f6b10da4b1a9f31cf9a9c7b30868f61522fe98accd69f1e5faf43608fc58962992bfb909f0850711a5c21025'
