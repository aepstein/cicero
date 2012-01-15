CarrierWave.configure do |config|
  config.root = "#{::Rails.root}/db/uploads/#{::Rails.env}"
end

