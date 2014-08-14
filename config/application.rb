require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module Cicero
  class Application < Rails::Application
    config.autoload_paths += %W(#{::Rails.root}/lib)
    config.encoding = "utf-8"
    config.action_mailer.default_url_options = {
      host: "assembly.cornell.edu/cicero", protocol: 'https' }
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.disable_implicit_join_references = true
    config.assets.enabled = true
    config.assets.version = '1.0'

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end

  end
end

