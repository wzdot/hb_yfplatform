#coding: utf-8
require 'net/http'
require 'json'

host = 'localhost'
port = 8080
domain = "http://#{host}"
client_id = '1484c0a29dfba8e0a8c305fe17052bba526bf7fd1b16a9efae6da1ad2b3349cc'
client_secret = '244ca2f368aec05f0b8ac90db8ecf5cec5e3679f370ce42838dd088729ac2849'
username = 'lv1@local.host'
password = '123456'

Net::HTTP.start(host, port) do |http|
  response = http.post('/oauth/token', "grant_type=password&client_id=#{client_id}&client_secret=#{client_secret}&username=#{username}&password=#{password}&scope=public+write")
  token = JSON.parse(response.body)['access_token']

  response = http.send_request('POST', '/api/composite/detections/faults_search', "name=变电&rows=20&page=1&faults=3,4,5", {'Authorization' => "Bearer #{token}"})
  p response.body


  # create
  # response = http.send_request('POST', '/api/members', 'user[email]=mega.yu@qq.com&user[password]=123456', {'Authorization' => "Bearer #{token}"})
  # data = JSON.parse(response.body)
  # id = data['id']
  # read
  # response = http.send_request('GET', "/api/members/#{id}", "" ,{'Authorization' => "Bearer #{token}"})
  # puts response.body

  # update
  # response = http.send_request('PUT', "/api/members/#{id}", 'user[password]=123456', {'Authorization' => "Bearer #{token}"})

  # delete
  # response = http.send_request('DELETE', "/api/members/#{id}", '', {'Authorization' => "Bearer #{token}"})


=begin
  http.post('/api/members', 'user[email]=mega.yu@qq.com&user[password]=123456', {'Authorization' => "Bearer #{token}"})
  response = http.get('/api/members', {'Authorization' => "Bearer #{token}"})
  p response.body
  response = http.get('/api/members/1', {'Authorization' => "Bearer #{token}"})
  p response.body

  http.send_request('PUT', '/api/members/1', 'user[password]=123456', {'Authorization' => "Bearer #{token}"})
=end
end
