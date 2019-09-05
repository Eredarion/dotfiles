local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

-- Set colors
local active_color
local background_color

if (colored_bar) then
  active_color = beautiful.temperature_bar_active_color or "#5AA3CC"
  background_color = beautiful.temperature_bar_background_color or "#222222"
else
  active_color = beautiful.xcolor4
  background_color = beautiful.bar_background
end

-- Configuration
local update_interval = 10            -- in seconds

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
  shape         = bar_shape,
  bar_shape     = bar_shape,
  color         = active_color,
  background_color = background_color,
  border_width  = 0,
  border_color  = beautiful.border_color,
  widget        = wibox.widget.progressbar,
}

local temperature_text = wibox.widget {
      align = "center",
      valign = "center",
      forced_height = dpi(10),
      font   = text_font ..  " medium 10",
      widget = wibox.widget.textbox
}

local temperature_hover = wibox.widget {
      temperature_text,
      visible = false,
      shape  = bar_shape,
      bg     = beautiful.xbgpure .. "80",
      widget = wibox.container.background
}

local temperature_widget = wibox.widget {
  temperature_bar,
  {
  temperature_hover,
  top = dpi(8),
  bottom = dpi(8),
  widget = wibox.container.margin
  },
  layout = wibox.layout.stack
}

temperature_widget:connect_signal("mouse::enter", function ()
                                 temperature_hover.visible = true
end)

temperature_widget:connect_signal("mouse::leave", function ()
                                 temperature_hover.visible = false
end)

-- local temperature_t = awful.tooltip {
--     objects        = { temperature_bar },
--     mode           = "outside",
--     margin_leftright = dpi(8),
--     margin_topbottom = dpi(5),
--     bg             = beautiful.xbackground,
--     fg             = beautiful.xforeground,
-- }

local function update_widget(temp)
  temperature_bar.value = tonumber(temp)
  temperature_text.markup = "<span font=\"".. text_font .. " bold" .."\" color=\"" ..  beautiful.xforeground .. "\">" .. temp:gsub("%s+", "") .. "°C</span>"
  -- temperature_t.markup = "CPU temperature: <span color=\"" .. "#FF6FC4" .. "\">" .. temp:gsub("%s+", "") .. "°C</span>"
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

return temperature_widget
