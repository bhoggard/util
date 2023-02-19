#!/usr/bin/env ruby

require 'airrecord'
require 'ndjson'

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Artist < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "artists"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/artists.ndjson")

for n in Artist.all
  data = {
    _id: n.id, 
    _type: "artist", 
    name: n["Name"],
    sortName: n["sort name"],
    homePage: n["home page"],
    birthYear: n["birth year"],
    deathYear: n["death year"],
    notes: n["notes"],
    email: n["email"],
    telephone: n["telelphone"],
    privateNotes: n["private notes"],
    gender: n["gender"]
  }
  if n["nationality"]&.first
    data[:nationality] = {_type: 'reference', _ref: n["nationality"]&.first}
  end
  generator.write(data)
end