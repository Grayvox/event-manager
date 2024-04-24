# frozen_string_literal: true

require 'csv'

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
  puts name
end
