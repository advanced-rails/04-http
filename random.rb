require 'httparty'
require 'pry'

print "Enter a number: "
num = gets.chomp
r = HTTParty.get("https://qrng.anu.edu.au/API/jsonI.php?length=#{num}&type=uint16").parsed_response
numbers = r['data']
p numbers
p numbers.sum / numbers.size
