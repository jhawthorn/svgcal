require "open-uri"
require "icalendar"

urls = File.read("#{ENV['HOME']}/.config/svgcal/urls").lines.map(&:strip)

all_events = []
urls.each do |url|
  cal_file = URI.open(url)
  cals = Icalendar::Calendar.parse(cal_file)
  p cals.size
  cal = cals.first
  all_events.concat cal.events
  #event = cal.events.first

  #puts "start date-time: #{event.dtstart}"
  #puts "start date-time timezone: #{event.dtstart.ical_params['tzid']}"
  #puts "summary: #{event.summary}"
end

now = Time.now
cutoff = now + (18 * 60 * 60) # next 18 hours

today_events = all_events.select { |event|
 start_time = event.dtstart.to_time.localtime
 finish_time = event.dtend.to_time.localtime
 finish_time > now && start_time < cutoff
}

binding.irb
