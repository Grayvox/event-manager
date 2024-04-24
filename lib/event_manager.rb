# frozen_string_literal: true

ATTENDEES = 'event_attendees.csv'
contents = File.read(ATTENDEES) if File.exist? ATTENDEES

puts 'Event Manager Initialized!'
puts contents
