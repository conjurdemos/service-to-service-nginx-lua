source 'https://rubygems.org'
ruby '2.0.0'

gem 'sinatra'
gem 'daemons'
begin
  gem 'conjur-api', git: 'git@github.com:conjurinc/api-ruby', branch: 'dsl'
  gem 'conjur-cli', git: 'git@github.com:conjurinc/cli-ruby', branch: 'dsl'
rescue
  gem 'conjur-cli'
end
