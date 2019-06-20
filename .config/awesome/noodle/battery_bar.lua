local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

local twenty_percent_notify = false
local two_percent_notify = false

-- Set colors
local active_color = beautiful.battery_bar_active_color or "#5AA3CC"
local background_color = beautiful.battery_bar_background_color or "#222222"

-- Configuration
local update_interval = 20            -- in seconds

local last_notification_id
local function send_notification(title, text, fg)
  notification = naughty.notify({
      title =  title,
      text = text,
      fg = fg,
      timeout = 7,
      icon = beautiful.battery_icon,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end

local battery_bar = wibox.widget{
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

-- Mouse control
-- battery_bar:buttons(gears.table.join(
--     -- 
--     awful.button({ }, 1, function ()
--     end),
--     -- 
--     awful.button({ }, 2, function () 
--     end),
--     -- 
--     awful.button({ }, 3, function () 
--     end),
--     -- 
--     awful.button({ }, 4, function () 
--     end),
--     awful.button({ }, 5, function () 
--     end)
-- ))

local function update_widget(bat)
  battery_bar.value = tonumber(bat)
end

local bat_script = [[
  bash -c "
  upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}'
  "]]

awful.widget.watch(bat_script, update_interval, function(widget, stdout)
                    local bat = stdout:gsub("%%", "")
                    -- local batlevel = bat:gsub("%s+", "")
                    -- bat = bat:gsub("%s+", "")
                    local batlevel = tonumber(bat)
                    
                    if ( batlevel <= 20 and twenty_percent_notify == false ) then
                        send_notification("Warning!~",
                                          "Battery level: <span color=\"" .. "#ef5350" .. "\">" .. batlevel .. "%</span>   ",
                                          beautiful.xforeground)
                        twenty_percent_notify = true
                    end

                    if ( batlevel <= 2 and two_percent_notify == false ) then
                        send_notification("Warning!", 
                                          "Battery level: " .. batlevel .. "%",
                                          "#ef5350")
                        two_percent_notify = true
                        awful.spawn.with_shell("poweroff")
                    end

                    if ( batlevel > 20 ) then
                       twenty_percent_notify = false
                       two_percent_notify = false
                    end

                    update_widget(bat)
end)

return battery_bar
