# frozen_string_literal: true

require 'csv'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

ATTENDEES = 'event_attendees.csv'
if File.exist?(ATTENDEES)
  contents = CSV.open(
    ATTENDEES,
    headers: true,
    header_converters: :symbol
  )
end

puts 'Event Manager Initialized!'
contents.each do |row|
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} - #{zipcode}"
end
