source 'http://rubygems.org'
gem 'rails', '~> 4.1.0'
gem 'mysql2'
gem 'rake'
gem 'activerecord-import'
gem 'exception_notification', '~> 4.0'
gem 'jc-validates_timeliness', '~> 3.1'
gem 'bcrypt-ruby'
gem 'squeel', '~> 1.2'
gem 'ransack'
gem 'declarative_authorization',
  git: 'git://github.com/aepstein/declarative_authorization.git',
  branch: 'rails4'
gem 'rmagick'
gem 'acts_as_list'
gem 'daemons'
gem 'carrierwave'
gem 'whenever', require: false
gem 'escape_utils'
gem 'valium', :git => 'git://github.com/jayrowe/valium.git'
gem 'cornell_assemblies_rails',
#  path: '/home/ari/code/cornell-assemblies-rails'
#  git: 'git://assembly.cornell.edu/git/cornell-assemblies-rails.git',
  git: 'https://github.com/aepstein/cornell-assemblies-rails.git',
  branch: '0-0-4'
gem 'cornell-assemblies-branding',
#  path: '/home/ari/code/cornell-assemblies-branding'
#  git: 'git://assembly.cornell.edu/git/cornell-assemblies-branding.git',
  git: 'https://github.com/aepstein/cornell-assemblies-branding.git',
  branch: '0-0-4'
gem 'fullcalendar-rails',
  git: 'https://github.com/bokmann/fullcalendar-rails.git'
group :production do
  gem 'sass-rails', '~> 4.0.2'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'execjs'
  gem 'therubyracer', require: 'v8'
  gem 'libv8'
end
group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'spring', require: false
  gem 'spring-commands-rspec', require: false
  gem 'spring-commands-cucumber', require: false
end
group :development do
  gem 'capistrano-rails', require: false
end
group :test do
  gem 'test-unit', require: false
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
  gem 'capybara-screenshot'
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', require: false
  gem 'factory_girl_rails', require: false
  gem 'email_spec', require: false
  gem 'launchy'
end

