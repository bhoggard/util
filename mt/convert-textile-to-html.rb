#!/usr/bin/env ruby

require "RedCloth"
require "sequel"

# client = Mysql2::Client.new(username: "root", database: "mt")

# results = client.query("SELECT * FROM mt_entry WHERE entry_convert_breaks='textile_2' limit 1")

# results.each do |row|
#   puts row["entry_id"]
#   converted = RedCloth.new(row["entry_text"]).to_html

#   # fix asset URLs for https
#   converted = converted.gsub("http://bloggy.com", "https://bloggy.com")

#   puts converted
# end

DB = Sequel.connect("mysql2://root@localhost:3306/mt")

entries = DB[:mt_entry]

entries.where(entry_convert_breaks: "textile_2").each do |row|
  id = row[:entry_id]
  puts id
  converted = RedCloth.new(row[:entry_text]).to_html
  # fix asset URLs for https
  converted.gsub!("http://bloggy.com", "https://bloggy.com")

  entries.where(entry_id: id).update(entry_text: converted, entry_convert_breaks: "__default__")
end
