CarrierWave.configure do |config|
  config.root = "#{::Rails.root}/db/uploads/#{::Rails.env}"
  config.base_path = "/system"
end

