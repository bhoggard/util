#!/usr/bin/env ruby

require "airrecord"
require "csv"
require "debug"
require "open-uri"

Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

class Artist < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "artists"
end

class Category < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "categories"
end

class Location < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "locations"
end

class Work < Airrecord::Table
  self.base_key = ENV["AIRTABLE_BASE_ID"]
  self.table_name = "works"

  has_one :artist, class: "Artist", column: "artist"
  has_one :category, class: "Category", column: "category"
  has_one :location, class: "Location", column: "location"
end

def acquisition_year_transform(s)
  if s.nil?
    ""
  else
    "06/01/#{s}"
  end
end

def type_transform(s)
  case s
  when "Drawing / Work on Paper"
    "Work on Paper"
  when "Artist Publication"
    "Other"
  when "Architecture and Design"
    "Other"
  when "Video"
    "Film/Video"
  else
    s
  end
end

works = Work.all
# w = works.first

# binding.break

header = [
  "Piece Name",	"Artist First Name",	"Artist Last Name",	"Inventory Number", "Medium",	"Type",
  "Status",	"Height",	"Width",	"Depth", "Dimension Override",	"Paper Height",	"Paper Width",	"Framed",
  "Framed Height",	"Framed Width",	"Framed Depth",	"Subject Matter",	"Price",	"Fair Market Value",
  "Wholesale Value", "Insurance Value",	"Creation Date",	"Circa",	"Creation date override",	"Description",
  "Tags",	"Notes",	"Collections",	"Current Location Name",	"Current Location Start Date",
  "Current Location End Date", "Sub Location Name", "Tertiary Location Name",	"Location Record Notes",
  "Location Record Longitude", "Location Record Latitude",	"Sale/Donation/Gift",	"Sale/Donation/Gift Date",
  "Sale/Donation/Gift Price",	"Sale Discount",	"Sale Commission",	"First Name/Company Name of who you sold/donated/gifted to",
  "Last Name of who you sold/donated/gifted to",	"Acquisition: Purchase Price",	"Acquisition: Purchase Date",
  "Acquisition: Purchase Location",	"Acquisition:  Purchase from First Name/Company Name",	"Acquisition: Purchase From Last Name",
  "Acquisition: Donation Date",	"Acquisition: Donation Value",	"Acquisition: Donor First Name/Company Name",
  "Acquisition: Donor Last",	"Attribution Line",	"Signed",	"Signature Notes", "Edition",	"Edition Info",	"Appraisal Date",
  "Appraisal Price", "Appraiser First Name",	"Appraiser Last Name",	"Condition Status", "Condition Notes",
  "Weight",	"Provenance Info", "Piece Image URLs", "Additional File URLs"
]

CSV.open(File.join(ENV["HOME"], "artwork-archive.csv"), "w") do |csv|
  csv << header

  works.each_with_index do |w, i|
    puts i

    w["public images"]&.each_with_index do |image, image_idx|
      download = URI.open(image["url"])
      IO.copy_stream(download, File.join(ENV["HOME"], "images", "#{image["id"]}-#{image["filename"]}"))
    end

    csv << [
      w["title"] || "Untitled",
      w.artist["first_name"],
      w.artist["last_name"],
      "", # Inventory Number
      w["medium"],
      type_transform(w&.category&.[]("Name")),
      "not_for_sale",
      "", # h
      "", # w
      "", # d
      w["dimensions"],
      "", # paper h
      "", # paper w
      "no", # framed
      *([""] * 8),
      w["acquisition year"],
      *([""] * 2),
      w["description"],
      "",
      w["private notes"],
      "",
      w&.location&.[]("Name"),
      *([""] * 14),
      w["price paid"],
      acquisition_year_transform(w["acquisition year"]),
      *([""] * 10),
      w["edition"] ? "yes" : "no",
      w["edition"],
      *([""] * 7),
      w["provenance"],
      w["public images"]&.map { |i| "#{i["id"]}-#{i["filename"]}" }&.join("|"),
      ""
    ]
  end
end
