# frozen_string_literal: true

require 'erb'
require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

# rubocop:disable Metrics/MethodLength
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end
# rubocop:enable Metrics/MethodLength

ATTENDEES = 'event_attendees.csv'
if File.exist?(ATTENDEES)
  contents = CSV.open(
    ATTENDEES,
    headers: true,
    header_converters: :symbol
  )
end

puts 'Event Manager initialized!'

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]
  zip = row[:zipcode]

  zipcode = clean_zipcode(zip)

  legislators = legislators_by_zipcode(zip)

  form_letter = erb_template.result(binding)
  puts form_letter
end
