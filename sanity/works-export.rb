#!/usr/bin/env ruby

require "airrecord"
require "ndjson"

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Work < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "works"
end

generator = NDJSON::Generator.new("#{ENV["HOME"]}/Downloads/works.ndjson")

Work.all.each do |n|
  data = {
    _id: n.id,
    _type: "work",
    artist: {_type: "reference", _ref: n["artist"].first},
    name: n["title"],
    year: n["year"],
    displayDate: n["display date as"],
    dimensions: n["dimensions"],
    medium: n["medium"],
    edition: n["edition"],
    acquisitionYear: n["acquisition year"],
    pricePaid: n["price paid"],
    featured: n["featured"],
    published: n["published"],
    imageSource: n["image source"]
  }

  if n["location"]
    data[:location] = {_type: "reference", _ref: n["location"].first}
  end

  if n["category"]
    data[:category] = {_type: "reference", _ref: n["category"].first}
  end

  if n["public images"]
    data[:publicImages] = n["public images"].map { |i| {_type: "image", originalFilename: "", _sanityAsset: "image@#{i["thumbnails"]["full"]["url"]}"} }
  end

  if n["tags"]
    data[:tags] = n["tags"].map { |i| {_type: "reference", _ref: i} }
  end

  generator.write(data)
end
