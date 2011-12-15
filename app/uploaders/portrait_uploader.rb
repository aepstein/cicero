class PortraitUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  include CarrierWave::Compatibility::Paperclip

  def paperclip_path
    ":rails_root/db/uploads/:rails_env/users/:attachment/:id_partition/:style/:basename.:extension"
  end

  def extension_white_list
    %w( jpg )
  end

  version :small do
    process :resize_to_fill => [300,300]
  end

  version :thumb do
    process :resize_to_fill => [100,100]
  end

end
