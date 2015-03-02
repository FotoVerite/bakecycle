Geocoder.configure(
  use_https: true,
  lookup: :google,
  api_key: ENV['GOOGLE_GEOCODER_API_KEY']
)
