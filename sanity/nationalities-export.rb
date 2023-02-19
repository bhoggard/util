#!/usr/bin/env ruby

require 'airrecord'
require 'ndjson'

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Nationality < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "nationalities"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/nationalities.ndjson")

for n in Nationality.all 
  generator.write({_id: n["ID"], _type: "nationality", name: n["Name"]})
end