require 'httparty'
require 'pry'

print "Enter a stock symbol: "
symbol = gets.chomp.upcase

while true
    r = HTTParty.get("https://www.google.com/finance/getprices?q=#{symbol}&x=NASD&i=120&p=15m&f=c&df=cpct").body
    price = r.split("\n").last.to_f.round(2)
    puts "#{symbol} => $#{price}"
    sleep 10
end
