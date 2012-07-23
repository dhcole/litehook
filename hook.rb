# hook.rb

require 'rubygems'
require 'sinatra'
require 'json'

get "*" do
    ""
    puts "get request"
end

post "/api" do
  request.body.rewind  # in case someone already read it
  data = JSON.parse(params[:payload])
  sha = data['after']
  repos = data['repository']['name']
  user = data['repository']['owner']['name']
  puts "post request ./run.sh #{user} #{repos} #{sha}"
  `./run.sh #{user} #{repos} #{sha}`
end
