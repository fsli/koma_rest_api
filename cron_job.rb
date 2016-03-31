require 'net/http'
port = 3000
host = "localhost"
path = "/api/v1/notifications/0"

req = Net::HTTP::Put.new(path, initheader = { 'Content-Type' => 'application/x-www-form-urlencoded'})
req.body = "is_pushed=true"
response = Net::HTTP.new(host, port).start {|http| http.request(req) }
puts response.code
