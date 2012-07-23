# hook.rb

require 'rubygems'
require 'sinatra'
require 'json'

post "/api" do
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  sha = data['after']
  repos = data['repository']['name']
  user = data['repository']['owner']['name']
  `./run.sh #{user} #{repos} #{sha} &> out.txt`
end
