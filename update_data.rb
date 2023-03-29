# Inspired by https://josh.fail/2022/dump-calendar-app-events-to-json/

require "date"
require "json"

ICBPS="#ICALBUDDY-PROPERTY-SEPARATOR#"
ICBNL="#ICALBUDDY-NEW-LINE#"
ICBSS="#ICALBUDDY-SECTION-SEPARATOR#"

Event = Struct.new(:title, :datetime, :notes) do
  def full_day?
    date_sections[1].nil?
  end

  def day
    Date.parse(date_sections[0])
  end

  def start_time
    if full_day?
      day.to_time
    else
      DateTime.parse("#{date_sections[0]} #{date_sections[1]}")
    end
  end

  def end_time
    if full_day?
      (day + 1).to_time
    else
      DateTime.parse("#{date_sections[0]} #{date_sections[1]}")
    end
  end

  def date_sections
    datetime =~ /\A(\d\d\d\d-\d\d-\d\d)(?: at (\d\d:\d\d) - (\d\d:\d\d))?\z/
    [$1, $2, $3]
  end

  def inspect
    "#<#{self.class} #{title} #{datetime}>"
  end
end

def fetch_events
  start_at = Time.now.to_s
  hour = 60 * 60
  end_at = (Time.now + 7 * 24 * hour).to_s

  p start_at

  output = nil

  cmd = %W[
  icalBuddy
  --propertySeparators |#{ICBPS}|
  --notesNewlineReplacement #{ICBNL}
  --noRelativeDates
  --dateFormat %Y-%m-%d
  --timeFormat %H:%M
  --bullet #{""}
  --includeEventProps title,datetime,notes
  --propertyOrder title,datetime,notes
  --noPropNames
  eventsFrom:#{start_at}
  to:#{end_at}
  ]

  output = IO.popen(cmd) do |io|
    io.read
  end

  data = output.lines(chomp: true).map do |line|
    title, datetime, notes = line.split(ICBPS)
    title.gsub!(/ \([^()]*\)\z/, "")
    notes&.gsub!(ICBNL, "\n")

    Event.new(title, datetime, notes)
  end

  data
end

events = fetch_events

upcoming = events.reject(&:full_day?)
upcoming = upcoming.first(5)
upcoming.map! { |event| [event.start_time.strftime("%H:%M"), event.title] }

File.write("events.json", JSON.dump(upcoming))

pp upcoming

