local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local helpers = require("helpers")


-- Configuration
local units = "metric"
local symbol = "°C"
-- Don't update too often, because your requests might get blocked for 24 hours
local update_interval = 1200         -- in seconds

local weather_text = wibox.widget{
    text = "Loading...",
    -- align  = 'center',
    valign = 'center',
    -- font = "sans 14",
    widget = wibox.widget.textbox
}

local weather_icon = wibox.widget.textbox(beautiful.whatever_icon)


local weather = wibox.widget{
  weather_icon,
  weather_text,
  layout = wibox.layout.fixed.horizontal
}

local function update_widget(icon_code, weather_details)
  -- Set icon
  if string.find(icon_code, "01d") then
    weather_icon.markup = helpers.colorize_text(beautiful.sun_icon , beautiful.xcolor3)
  elseif string.find(icon_code, "01n") then
    weather_icon.markup = helpers.colorize_text(beautiful.star_icon , beautiful.xcolor6)
  elseif string.find(icon_code, "02d") then
    weather_icon.markup = helpers.colorize_text(beautiful.dcloud_icon , beautiful.xcolor2)
  elseif string.find(icon_code, "02n") then
    weather_icon.markup = beautiful.ncloud_icon
  elseif string.find(icon_code, "03") or string.find(icon_code, "04") then
    weather_icon.markup = beautiful.cloud_icon
  elseif string.find(icon_code, "09") or string.find(icon_code, "10") then
    weather_icon.markup = beautiful.rain_icon
  elseif string.find(icon_code, "11") then
    weather_icon.markup = helpers.colorize_text(beautiful.storm_icon , beautiful.xcolor5)
  elseif string.find(icon_code, "13") then
    weather_icon.markup = beautiful.snow_icon
  elseif string.find(icon_code, "50") or string.find(icon_code, "40") then
    weather_icon.markup = beautiful.mist_icon
  else
    weather_icon.markup = beautiful.whatever_icon
  end

  -- Set text --
  -- Replace -0 with 0 degrees
  weather_details = string.gsub(weather_details, '%-0', '0')
  -- Capitalize first letter of the description
  weather_details = weather_details:sub(1,1):upper()..weather_details:sub(2)
  weather_text.markup = weather_details
end

local weather_details_script = [[
  bash -c '
  KEY="]]..api_key..[["
  CITY="]]..city_id..[["
  UNITS="]]..units..[["
  SYMBOL="]]..symbol..[["

  weather=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?APPID=$KEY&id=$CITY&units=$UNITS")

  if [ ! -z "$weather" ]; then
    weather_temp=$(echo "$weather" | jq ".main.temp" | cut -d "." -f 1)
    weather_icon=$(echo "$weather" | jq -r ".weather[].icon" | head -1)
    weather_description=$(echo "$weather" | jq -r ".weather[].description" | head -1)

    echo "$weather_icon" "$weather_description" "$weather_temp$SYMBOL"
  else
    echo "... Info unavailable"
  fi
']]

awful.widget.watch(weather_details_script, update_interval, function(widget, stdout)
                     local icon_code = string.sub(stdout, 1, 3)
                     local weather_details = string.sub(stdout, 5)
                     weather_details = string.gsub(weather_details, '^%s*(.-)%s*$', '%1')
                     update_widget(icon_code, weather_details)
end)

return weather
