#!/usr/bin/env ruby

require "airrecord"
require "ndjson"

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Category < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "locations"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/locations.ndjson")

Category.all.each do |n|
  generator.write({_id: n.id, _type: "location", name: n["Name"]})
end
