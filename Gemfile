source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in zaikio.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.

# gemspec # this will not work as spec.name == 'zaikio-oauth_client' but Engine name is Zaikio
gem 'zaikio-oauth_client'

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'rest_jeweler', github: 'crispymtn/rest_jeweler'

gem 'haml-rails'
gem 'webpacker'
gem 'sass-rails'
gem 'pg'

# To use a debugger
gem 'byebug', group: [:development, :test]

group :development do
  gem 'web-console'
  gem 'pry-rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'puma'
end
