local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Set colors
local active_color = beautiful.xcolor6
local background_color = beautiful.bar_background

-- Configuration
local update_interval = 30            -- in seconds


local disk_bar = wibox.widget{
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


local disk_text = wibox.widget {
      align = "center",
      valign = "center",
      forced_height = dpi(10),
      font   = text_font ..  " medium 10",
      widget = wibox.widget.textbox
}

local disk_hover = wibox.widget {
      disk_text,
      visible = false,
      shape  = bar_shape,
      bg     = beautiful.xbgpure .. "80",
      widget = wibox.container.background
}

local disk_widget = wibox.widget {
  disk_bar,
  {
  disk_hover,
  top = dpi(8),
  bottom = dpi(8),
  widget = wibox.container.margin
  },
  layout = wibox.layout.stack
}


disk_widget:connect_signal("mouse::enter", function ()
                  disk_hover.visible = true
end)

disk_widget:connect_signal("mouse::leave", function ()
                  disk_hover.visible = false
end)


local function update_widget(percent, free)
  disk_bar.value = tonumber(percent)
  disk_text.markup = "<span font=\"".. text_font .. " bold" .."\" \
                           color=\"" ..  beautiful.xforeground .. "\">" .. "Free: " .. free .. "gb" .. "</span>" 
end


local disk_script = [[
  bash -c "
  df -h | grep ']] .. root_disk .. [[' | awk '{print $5, $4 }'
  "]]


awful.widget.watch(disk_script, update_interval, function(widget, stdout)
                    local s, e, percent, free = string.find(stdout, "(%d+)[^%d]*(%d+)")
                    update_widget(percent, free)
end)

return disk_widget
