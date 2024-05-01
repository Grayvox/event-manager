# frozen_string_literal: true

require 'erb'
require 'csv'
require 'date'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(number)
  only_numbers = number.gsub(/[^\d]/, '')
  if only_numbers.length == 10
    only_numbers
  elsif only_numbers.length == 11 && only_numbers.start_with?('1')
    only_numbers[1..10]
  else
    'No valid phone number found!'
  end
end

def find_most_common(array = [])
  array.max_by { |element| array.count(element) }
end

def find_day_of_week(day_value)
  days = {
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday'
  }
  days[day_value]
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
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end
# rubocop:enable Metrics/MethodLength

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
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

puts 'Event Manager initialized!'

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

reg_dates = []
hours_collection = []
days_collection = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  date = row[:regdate]

  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)

  date_time = Time.strptime(date, '%m/%d/%y %H:%M')
  hours_collection.push(date_time.hour)
  days_collection.push(date_time.wday)

  puts phone_number
  save_thank_you_letter(id, form_letter)
end

puts "The most common HOUR of registration is #{find_most_common(hours_collection)}"
puts "The most common DAY OF THE WEEK for registration is #{find_day_of_week(find_most_common(days_collection))}"
