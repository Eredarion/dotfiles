local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

-- Set colors
local active_color = beautiful.temperature_bar_active_color or "#5AA3CC"
local background_color = beautiful.temperature_bar_background_color or "#222222"

-- Configuration
local update_interval = 15            -- in seconds

local heat_notify = false
local last_notification_id
local function send_notification(title, text)
  notification = naughty.notify({
      title =  title,
      text = text,
      timeout = 5,
      icon = beautiful.temperature_icon,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end

local temperature_bar = wibox.widget{
  max_value     = 100,
  value         = 50,
  forced_height = dpi(10),
  margins       = {
    top = dpi(8),
    bottom = dpi(8),
  },
  forced_width  = dpi(200),
  shape         = gears.shape.rounded_bar,
  bar_shape     = gears.shape.rounded_bar,
  color         = active_color,
  background_color = background_color,
  border_width  = 0,
  border_color  = beautiful.border_color,
  widget        = wibox.widget.progressbar,
}

local temperature_t = awful.tooltip {
    objects        = { temperature_bar },
    mode           = "outside",
    margin_leftright = dpi(8),
    margin_topbottom = dpi(5),
    bg             = beautiful.xbackground,
    fg             = beautiful.xforeground,
}

local function update_widget(temp)
  temperature_bar.value = tonumber(temp)
  temperature_t.markup = "CPU temperature: <span color=\"" .. "#FF6FC4" .. "\">" .. temp:gsub("%s+", "") .. "</span>"
end

local temp_script = [[
  bash -c "
  sensors | grep Package | awk '{print $4}' | cut -c 2-3
  "]]

awful.widget.watch(temp_script, update_interval, function(widget, stdout)
                    local temp = stdout

                    local templevel = tonumber(temp)

                    if ( templevel >= 75 and heat_notify == false ) then
                        send_notification("Warning!~",
                                          "Temperature: <span color=\"" .. "#ef5350" .. "\">" .. templevel .. "°C</span>   ")
                        heat_notify = true
                    end

                    if ( templevel < 65 ) then
                         heat_notify = false
                    end
                    update_widget(temp)
end)

return temperature_bar
