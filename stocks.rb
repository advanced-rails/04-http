require 'httparty'
require 'pry'

### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###

class Stock
    def self.quote(symbol)
        r = HTTParty.get("https://www.google.com/finance/getprices?q=#{symbol.upcase}&x=NASD&i=120&p=15m&f=c&df=cpct").body
        r.split("\n").last.to_f.round(2)
    end
end

### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###

class Client
    attr_reader :name, :balance

    @@curl = 'https://stocks.stamplayapp.com/api/cobject/v1/clients'
    @@turl = 'https://stocks.stamplayapp.com/api/cobject/v1/transactions'

    def self.find(name)
        rsp = HTTParty.get("#{@@curl}?name=#{name}&populate=true").parsed_response
        if rsp['pagination']['total_elements'] == 1
           i = rsp['data'][0]['id']
           n = rsp['data'][0]['name']
           b = rsp['data'][0]['balance']
           t = rsp['data'][0].has_key?('transactions') ? rsp['data'][0]['transactions'] : []
           Client.new(i, n, b, t)
        end
    end
    
    def self.create(name, balance)
        HTTParty.post(@@curl, {body: {name: name, balance: balance}})
        Client.find(name)
    end
    
    def initialize(id, name, balance, transactions)
        @id = id
        @name = name
        @balance = balance
        @tids = transactions.map {|t| t['id']}
        @transactions = transactions
    end
    
    def purchase(quantity, symbol)
        price = Stock.quote(symbol)
        total = price * quantity
        return if total > @balance
        tid = HTTParty.post(@@turl, {body: {price: price, quantity: quantity, symbol: symbol, total: total}}).parsed_response['id']
        @balance -= total
        @tids << tid
    end
    
    def update
        HTTParty.put("#{@@curl}/#{@id}", {body: {balance: @balance, transactions: @tids}})
    end
    
    def transactions
        @transactions.map {|t| {price: t['price'], quantity: t['quantity'], symbol: t['symbol'], total: t['total']}}
    end
end

### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###
### --------------------------------------------------------------------------------------- ###

while true
    puts "(1) - Find Account"
    puts "(2) - Create Account"
    puts "(3) - Buy Stock"
    puts "(4) - View Balance"
    puts "(5) - Stock Quote"
    puts "(6) - View Purchases"
    puts "(7) - Quit"
    print ": "    
    val = gets.to_i
    break if val == 7
    
    if val == 1
        print "Name: "
        name = gets.chomp
        client = Client.find(name)
        p client
    elsif val == 2
        print "Name: "
        name = gets.chomp
        print "Balance: "
        balance = gets.to_f
        client = Client.create(name, balance)
        p client
    elsif val == 3
        print "Amount: "
        shares = gets.to_i
        print "Symbol: "
        symbol = gets.chomp
        client.purchase(shares, symbol)
        client.update
        client = Client.find(client.name)
    elsif val == 4
        p client.balance
    elsif val == 5
        print "Symbol: "
        symbol = gets.chomp
        p Stock.quote(symbol)
    elsif val == 6
        p client.transactions
    end
end
