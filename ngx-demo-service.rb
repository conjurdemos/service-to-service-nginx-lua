#!/usr/bin/env ruby
require 'sinatra'
set :port, 3535

not_found do
  "Not found: #{request.path_info}\n"
end

get '/:privilege/:resource' do |privilege, resource|
  "Performed action '#{privilege}' on '#{resource}'\n"
end
