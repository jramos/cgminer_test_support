# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'bundler-audit',  '>= 0.9'
  gem 'rake',           '>= 13.2'
  gem 'rspec',          '>= 3.13'
  gem 'simplecov',      '>= 0.22'
end

# RuboCop and its plugins drop older Ruby versions faster than the gem itself.
# Keep them in a separate :lint group so the test matrix can skip them via
# BUNDLE_WITHOUT=lint and stay green on the gem's minimum supported Ruby.
group :development, :lint do
  gem 'rubocop',        '>= 1.60'
  gem 'rubocop-rake',   '>= 0.6'
  gem 'rubocop-rspec',  '>= 2.27'
end
