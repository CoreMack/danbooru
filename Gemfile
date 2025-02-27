source 'https://rubygems.org/'

gem 'dotenv-rails', :require => "dotenv/rails-now"

gem "rails", "~> 7.0"
gem "pg"
gem "simple_form"
gem "sanitize"
gem 'ruby-vips'
gem 'diff-lcs', :require => "diff/lcs/array"
gem 'bcrypt', :require => "bcrypt"
gem 'rubyzip', :require => "zip"
gem 'stripe'
gem 'aws-sdk-sqs', '~> 1'
gem 'responders'
gem 'dtext_rb', git: "https://github.com/danbooru/dtext_rb.git", require: "dtext"
gem 'memoist'
gem 'daemons'
gem 'oauth2'
gem 'bootsnap'
gem 'addressable'
gem 'rakismet'
gem 'recaptcha', require: "recaptcha/rails"
gem 'activemodel-serializers-xml'
gem 'webpacker', '= 6.0.0.rc.6'
gem 'rake'
gem 'redis'
gem 'builder'
# gem 'did_you_mean' # github.com/yuki24/did_you_mean/issues/117
gem 'puma'
gem 'scenic'
gem 'ipaddress_2'
gem 'http'
gem 'activerecord-hierarchical_query'
gem 'http-cookie', git: "https://github.com/danbooru/http-cookie"
gem 'pundit'
gem 'mail'
gem 'nokogiri'
gem 'view_component'
gem 'tzinfo-data'
gem 'hsluv'
gem 'google-cloud-bigquery', require: "google/cloud/bigquery"
gem 'google-cloud-storage', require: "google/cloud/storage"
gem 'ed25519'
gem 'bcrypt_pbkdf' # https://github.com/net-ssh/net-ssh/issues/565
gem 'terminal-table'
gem 'newrelic_rpm', require: false
gem 'clockwork'
gem 'puma-metrics'
gem 'puma_worker_killer'
gem "rack-timeout", require: "rack/timeout/base"
gem "parallel"
gem "pry-byebug"
gem "pry-rails"
gem "ffi"
gem "rbtrace"
gem "good_job"
gem "crass"
gem "public_suffix"

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  #gem 'meta_request'
  gem 'rack-mini-profiler'
  gem 'stackprof'
  gem 'flamegraph'
  gem 'memory_profiler'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'benchmark-ips', require: "benchmark/ips"
  gem 'listen'
  gem 'solargraph'
  gem 'derailed_benchmarks'
end

group :test do
  gem "shoulda-context"
  gem "shoulda-matchers"
  gem "factory_bot"
  gem "mocha", require: "mocha/minitest"
  gem "ffaker"
  gem "simplecov", require: false
  gem "minitest-ci"
  gem "minitest-reporters", require: "minitest/reporters"
  gem "mock_redis"
  gem "capybara"
  gem "selenium-webdriver"
  gem "codecov", require: false
  gem 'stripe-ruby-mock', require: "stripe_mock"
end
