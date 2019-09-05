local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local helpers = require("helpers")
local pad = helpers.pad


local twenty_percent_notify = false
local two_percent_notify = false

local icon_font = "Tinos Nerd Font 20"
local icon_size = dpi(36)
local progress_bar_width = dpi(215)


-- Set colors
local active_color
local background_color

if (colored_bar) then
  active_color = beautiful.battery_bar_active_color or "#5AA3CC"
  background_color = beautiful.battery_bar_background_color or "#222222"
else
  active_color = beautiful.xcolor7
  background_color = beautiful.bar_background
end


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
  shape         = bar_shape,
  bar_shape     = bar_shape,
  color         = active_color,
  background_color = background_color,
  border_width  = 0,
  border_color  = beautiful.border_color,
  widget        = wibox.widget.progressbar,
}

local battery_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>")
battery_icon.resize = true
battery_icon.forced_width = icon_size
battery_icon.forced_height = icon_size

battery_bar.forced_width = progress_bar_width

local battery_widget = wibox.widget{
  nil,
  {
    battery_icon,
    pad(1),
    battery_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}


local function update_widget(bat)
  battery_bar.value = tonumber(bat)
end


local bat_script = [[
  bash -c "
  upower -i $(upower -e | grep BAT)
  "]]


awful.widget.watch(bat_script, update_interval, function(widget, stdout)
                    local percentage = string.match(stdout, 'percentage:%s*(%S+)')
                    local state = string.match(stdout, 'state:%s*(%S+)')

                    local bat = percentage:gsub("%%", "")
                    -- local batlevel = bat:gsub("%s+", "")
                    -- bat = bat:gsub("%s+", "")
                    local batlevel = tonumber(bat)
                    
                    -- Icon --
                    if (state == "discharging") then
                        battery_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>"
                    else
                        battery_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>"
                    end
                    ----------

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

return battery_widget
