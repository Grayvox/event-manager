# frozen_string_literal: true

require 'csv'

def clean_zipcode(zipcode)
  if zipcode.nil?
    '00000'
  elsif zipcode.length < 5
    zipcode.rjust(5, '0')
  elsif zipcode.length > 5
    zipcode[0..4]
  end
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
