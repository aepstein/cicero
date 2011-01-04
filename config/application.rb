require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module Cicero
  class Application < Rails::Application
    config.autoload_paths += %W(#{Rails.root}/lib)
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation]
    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui jquery-ui-timepicker-addon rails)

    def self.app_config
      @@app_config ||= YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]
    end

  end
end

