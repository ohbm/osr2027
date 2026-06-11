#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
YEAR = 2026
TIMEZONE = "Europe/Paris"
OUTPUT_PATH = File.join(ROOT, "downloads", "OSRschedule.ics")
SCHEDULE_PATH = File.join(ROOT, "_data", "osr_schedule.yml")
SESSIONS_PATH = File.join(ROOT, "_data", "osr_sessions.yml")
ROOMS_PATH = File.join(ROOT, "_data", "osr_rooms.yml")
CONFIG_PATH = File.join(ROOT, "_config.yml")
DTSTAMP = "20260514T000000Z"

def read_yaml(path)
  YAML.safe_load(File.read(path), aliases: true)
end

def config_url(config)
  site_url = config.fetch("url")
  baseurl = config.fetch("baseurl", "")
  "#{site_url}#{baseurl}"
end

def event_title(event)
  case event["category"]
  when "panel"
    "Panel #{event.fetch("number")}: #{event.fetch("title")}"
  when "tabletalk"
    "Table Talk #{event.fetch("number")}: #{event.fetch("title")}"
  else
    event.fetch("title")
  end
end

def local_datetime(day_id, time_text)
  month, day = day_id.split("-").map(&:to_i)
  hour, minute = time_text.split(":").map(&:to_i)
  raise ArgumentError, "Invalid day id: #{day_id.inspect}" unless month && day
  raise ArgumentError, "Invalid time: #{time_text.inspect}" unless hour && minute

  DateTime.new(YEAR, month, day, hour, minute, 0)
end

def ics_datetime(datetime)
  datetime.strftime("%Y%m%dT%H%M%S")
end

def gcal_datetime(datetime)
  datetime.strftime("%Y%m%dT%H%M%S")
end

def escape_text(value)
  value.to_s
       .gsub("\\", "\\\\\\")
       .gsub("\n", "\\n")
       .gsub(";", "\\;")
       .gsub(",", "\\,")
end

def fold_line(line)
  bytes = line.b
  return line if bytes.bytesize <= 75

  folded = bytes.byteslice(0, 75)
  bytes = bytes.byteslice(75..)&.dup || +""

  until bytes.empty?
    chunk = bytes.byteslice(0, 74)
    folded << "\r\n " << chunk
    bytes = bytes.byteslice(74..)&.dup || +""
  end
  folded
end

def property(name, value)
  fold_line("#{name}:#{value}")
end

def event_url(site_base, event)
  path = event.fetch("page_url")

  if path.include?("://")
    path
  elsif event["anchor"]
    "#{site_base}#{path}##{event.fetch("anchor")}"
  else
    "#{site_base}#{path}"
  end
end

def event_room(event, rooms)
  override = rooms.fetch("overrides", []).find do |candidate|
    candidate.fetch("id") == event.fetch("id")
  end
  override ? override.fetch("room") : rooms.fetch("default")
end

schedule = read_yaml(SCHEDULE_PATH)
sessions = read_yaml(SESSIONS_PATH).each_with_object({}) do |session, index|
  index[session.fetch("id")] = session
end
rooms = read_yaml(ROOMS_PATH)
site_base = config_url(read_yaml(CONFIG_PATH))

lines = [
  "BEGIN:VCALENDAR",
  "VERSION:2.0",
  "PRODID:-//OHBM//OSR 2026//EN",
  "CALSCALE:GREGORIAN",
  "METHOD:PUBLISH",
  property("X-WR-CALNAME", escape_text("OHBM Open Science Room 2026")),
  property("X-WR-TIMEZONE", TIMEZONE),
  "BEGIN:VTIMEZONE",
  "TZID:Europe/Paris",
  "BEGIN:DAYLIGHT",
  "TZOFFSETFROM:+0100",
  "TZOFFSETTO:+0200",
  "TZNAME:CEST",
  "DTSTART:19700329T020000",
  "RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU",
  "END:DAYLIGHT",
  "BEGIN:STANDARD",
  "TZOFFSETFROM:+0200",
  "TZOFFSETTO:+0100",
  "TZNAME:CET",
  "DTSTART:19701025T030000",
  "RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU",
  "END:STANDARD",
  "END:VTIMEZONE"
]

schedule.fetch("days").each do |day|
  day.fetch("entries").each do |entry|
    event = if entry["session_id"]
              sessions.fetch(entry.fetch("session_id")) do
                raise KeyError, "No session found for #{entry.fetch("session_id").inspect}"
              end
            else
              entry
            end

    start_at = local_datetime(day.fetch("id"), event.fetch("start_time"))
    end_at = local_datetime(day.fetch("id"), event.fetch("end_time"))
    raise ArgumentError, "Event ends before it starts: #{event.fetch("id")}" unless end_at > start_at
    if event["gcal_start"] && event["gcal_start"] != gcal_datetime(start_at)
      raise ArgumentError, "gcal_start does not match schedule time for #{event.fetch("id")}"
    end
    if event["gcal_end"] && event["gcal_end"] != gcal_datetime(end_at)
      raise ArgumentError, "gcal_end does not match schedule time for #{event.fetch("id")}"
    end

    uid = "osr2026-#{event.fetch("id")}@ohbm.github.io"
    url = event_url(site_base, event)
    room = event_room(event, rooms)
    description = "OHBM Open Science Room 2026 session. Full schedule: #{site_base}/schedule/"

    lines.concat(
      [
        "BEGIN:VEVENT",
        property("UID", uid),
        property("DTSTAMP", DTSTAMP),
        property("DTSTART;TZID=#{TIMEZONE}", ics_datetime(start_at)),
        property("DTEND;TZID=#{TIMEZONE}", ics_datetime(end_at)),
        property("SUMMARY", escape_text(event_title(event))),
        property("DESCRIPTION", escape_text(description)),
        property("LOCATION", escape_text(room)),
        property("URL", url),
        "END:VEVENT"
      ]
    )
  end
end

lines << "END:VCALENDAR"

FileUtils.mkdir_p(File.dirname(OUTPUT_PATH))
File.write(OUTPUT_PATH, "#{lines.join("\r\n")}\r\n")

puts "Wrote #{OUTPUT_PATH}"
