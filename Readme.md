Required Softwares :

Ruby
Rubygems
Sqlite3

Gems need to install

gem install sqlite3 #db connection
gem install active_record # to store data to database
gem install mechanize #to scrape the webpage
gem install terminal-table #to display the table like structure in command prompt


Steps to run the program

To scrape the data
ruby videogamescrape.rb update 

To search in the scraped data
ruby videogamescrape.rb search call # search for call in the scraped data

To show the history for specific product

ruby videogamescrape.rb history 181 # to show the history for product 181