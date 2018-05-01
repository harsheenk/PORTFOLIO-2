require "rubygems"
require "active_record"
require 'pp'
require 'mechanize'
require 'terminal-table'

ActiveRecord::Base.establish_connection({
                                          :adapter => "sqlite3",
                                          :host => "localhost",
                                          :database => "db/development.sqlite3"
                                        })


ActiveRecord::Schema.define do

  create_table :games do |t|
    t.column :name, :string
    t.column :price, :float
    t.column :site, :string
    t.column :currency, :string
    t.column :created_at, :datetime
  end

end unless ActiveRecord::Base.connection.table_exists? 'games'

class Game < ActiveRecord::Base

end



def update
  pp "Updating Prices from Site /www.gamestheshop.com/bucket/new-releases/3"
  from_site_a = 0
  agent = Mechanize.new
  page  = agent.get("http://www.gamestheshop.com/bucket/new-releases/3")
  page.search(".ProductBox").each do |game_product|
    name = game_product.search(".productTitle a").text
    currency = game_product.search(".PBRs").text
    currency = currency.gsub(".", '')
    price = game_product.search(".spnGTSPrice").text
    price = price.gsub(",", '') if price
    price = price.to_f
    if Game.create(name: name, currency: currency, price: price, site: 'gamestheshop', created_at: Time.now)
      from_site_a += 1
    end
  end

  pp "gamestheshop update complete. #{from_site_a} prices inserted"


  from_site_b = 0
  page = agent.get("http://gameloot.in/product-category/buy-games/page/2/?pa_platforms=ps4")
  page.search(".kad_product").each do |game_product|
    name = game_product.search(".product_details a h5").text
    currency = game_product.search(".woocommerce-Price-currencySymbol")[0].text
    currency = currency.gsub(".", '')
    price = game_product.search(".woocommerce-Price-amount")[0].text.scan(/\d/).join('').to_f
    if Game.create(name: name, currency: currency, price: price, site: 'gameloot', created_at: Time.now)
      from_site_b += 1
    end
  end

  pp "gameloot update complete. #{from_site_b} prices inserted"

end

def search(text)
  if text.present?
    games = Game.where("lower(name) like ?", "%#{text.downcase}%")
    data = games.map{|game| [game.id, game.name, game.site, "#{game.currency}#{game.price}"]}
    table = Terminal::Table.new :headings => ['#', 'Name', 'Store', 'Price'], :rows => data
    puts table
  end
end

def history(id)
  game = Game.find(id)
  if game
    games = Game.where(name: game.name)
  else
    games = "No record"
  end
  data = games.map{|game| [game.created_at.strftime("%d/%m/%Y"), game.created_at.strftime("%H:%M"), "#{game.currency}#{game.price}"]}
  table = Terminal::Table.new :headings => ['Date', 'Time', 'Price'], :rows => data
  puts table
end


v1 = ARGV[0]
v2 = ARGV[1]

if v1 == 'update'
  update
elsif v1 == 'search'
  search(v2)
elsif v1 == 'history'
  history(v2)
end
