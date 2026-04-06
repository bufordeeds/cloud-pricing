source "https://rubygems.org"

gem "rails", "~> 7.2.3", ">= 7.2.3.1"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

# App-specific gems
gem "oj"
gem "pagy", "~> 9.0"
gem "chartkick"
gem "groupdate"
gem "httparty"
gem "resend", "~> 1.1"
gem "rack-cors", "~> 2.0"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
end
