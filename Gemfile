source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "haml-rails"
gem "sass-rails"
gem "webpacker"

# To use a debugger
gem "byebug", group: %i[development test]

group :development do
  gem "pry-rails"
  gem "web-console"
end

group :development, :test do
  gem "mocha", require: false
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "webmock", require: false
end
