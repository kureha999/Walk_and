require "carrierwave/storage/abstract"
require "carrierwave/storage/file"
require "carrierwave/storage/fog"

CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = "fog/aws"
    config.fog_directory  = "walk-and"
    config.fog_public = false
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV["RAILS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["RAILS_SECRET_ACCESS_KEY"],
      region: "ap-northeast-1"
    }
  else
    config.storage :file
    config.enable_processing = true if Rails.env.development?
    config.enable_processing = false if Rails.env.test?
  end
end
