#!/usr/bin/env ruby
require 'daemons'
pwd = File.expand_path("..", __FILE__)
Daemons.run_proc 'ngx-demo-service.rb', dir_mode: :normal, dir: "#{pwd}/var" do
  Dir.chdir(pwd)
  exec "bundle exec ruby ngx-demo-service.rb"
end
