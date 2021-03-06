ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

#ActiveRecord::Migration.check_pending!
# The following line can be uncommented at Rails 4.1
#ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

require 'factory_girl_rails'

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include ActionDispatch::TestProcess
  config.after(:all) do
    data_directory = File.expand_path(File.dirname(__FILE__) + "../../db/uploads/#{ENV['RAILS_ENV']}")
    if File.directory?(data_directory)
      FileUtils.rm_rf data_directory
    end
  end
  config.include FactoryGirl::Syntax::Methods
end

