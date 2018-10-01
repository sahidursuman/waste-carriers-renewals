source "https://rubygems.org"
ruby "2.4.2"

# Declare your gem's dependencies in flood_risk_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Use Airbrake for error reporting to Errbit
# Version 6 and above cause errors with Errbit, so use 5.8.1 for now
gem "airbrake", "5.8.1"

# GOV.UK styling
gem "govuk_elements_rails", "~> 3.1"
gem "govuk_template", "~> 0.23"

# Use jquery as the JavaScript library
gem "jquery-rails"

# Use MongoDB as the database
gem "mongoid", "~> 5.2"

# Use CanCanCan for user roles and permissions
# Version 2.0 doesn't support Mongoid, so we're locked to an earlier one
gem "cancancan", "~> 1.10"

# Use Devise for user authentication
gem "devise", ">= 4.4.3"

gem "secure_headers", "~> 5.0"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks"

# Generates a PDF from HTML, in our case, the users certificate
gem 'wicked_pdf'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "dotenv-rails"
  gem "rspec-rails", "~> 3.6"
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :production do
  # Used for Heroku logging and asset serving
  gem "rails_12factor"
end

group :test do
  gem "database_cleaner"
  gem "factory_bot_rails", require: false
  gem "simplecov", require: false
  gem "timecop"
  gem "vcr", "~> 4.0"
  gem "webmock", "~> 3.4"
end
gem "loofah", ">= 2.2.1"
gem "rails-html-sanitizer", ">= 1.0.4"
