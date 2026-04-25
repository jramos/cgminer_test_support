# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'bundler-audit',  '>= 0.9'
  gem 'rake',           '>= 13.2'
  gem 'rspec',          '>= 3.13'
  gem 'rubocop',        '>= 1.60'
  gem 'rubocop-rake',   '>= 0.6'
  gem 'rubocop-rspec',  '>= 2.27'
  gem 'simplecov',      '>= 0.22'

  # parallel 2.1.0 dropped Ruby 3.2 support. Pin until the gem's
  # minimum supported Ruby is 3.3+. (rubocop pulls parallel transitively.)
  gem 'parallel', '< 2.0'
end
