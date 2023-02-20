#!/usr/bin/env ruby

require 'airrecord'
require 'ndjson'

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Category < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "categories"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/categories.ndjson")

for n in Category.all 
  generator.write({_id: n.id, _type: "category", name: n["Name"]})
end