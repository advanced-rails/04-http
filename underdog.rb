require 'httparty'

url = 'https://temp3.stamplayapp.com/api/cobject/v1/dog'

10.times do |i|
    name = "rex #{i}"
    age = i * i
    weight = (i/0.2) + 100
    HTTParty.post(url, {body: {name: name, age: age, weight: weight}})
end

r = HTTParty.get(url).parsed_response
p r
