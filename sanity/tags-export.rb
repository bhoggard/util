#!/usr/bin/env ruby

require "airrecord"
require "ndjson"

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Tag < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "tags"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/tags.ndjson")

Tag.all.each do |n|
  generator.write({_id: n.id, _type: "tag", name: n["Name"]})
end
