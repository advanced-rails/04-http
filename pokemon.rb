require 'httparty'
require 'pry'

print "Enter a number: "
num = gets.chomp
r = HTTParty.get("http://pokeapi.co/api/v2/type/#{num}").parsed_response
names = r['pokemon'].map {|p| p['pokemon']['name']}
p names
