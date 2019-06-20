local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

-- Set colors
local active_color = beautiful.ram_bar_active_color or "#5AA3CC"
local background_color = beautiful.ram_bar_background_color or "#222222"

local last_notification_id
local function send_notification(title, text)
  notification = naughty.notify({
      title =  title,
      text = text,
      timeout = 5,
      icon = beautiful.ram_icon,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end

local large_memory_usage_notify = false

-- Configuration
local update_interval = 10            -- in seconds

-- local ram_bar = wibox.widget {
--   {
--     max_value     = 100,
--     value         = 50,
--     forced_height = dpi(10),
--     margins       = {
--       top = dpi(8),
--       bottom = dpi(8),
--     },
--     forced_width  = dpi(200),
--     shape         = gears.shape.rounded_bar,
--     bar_shape     = gears.shape.rounded_bar,
--     color         = active_color,
--     background_color = background_color,
--     border_width  = 0,
--     border_color  = beautiful.border_color,
--     widget        = wibox.widget.progressbar,
--   },
--   {
--       -- markup = '<b><span foreground="' .. beautiful.xbackground .. '">hello ' ..  ..'hyu</span></b>',
--       align = "center",
--       valign = "center",
--       fg     = beautiful.xbackground,
--       widget = wibox.widget.textbox,
--   },
--   layout = wibox.layout.stack
-- }

local ram_bar = wibox.widget {
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

local bar_text = wibox.widget {
      align = "center",
      valign = "center",
      visible = false,
      widget = wibox.widget.textbox
}

local widget_mew = wibox.widget {
  ram_bar,
  {
    {
      bar_text,
      shape  = gears.shape.rounded_bar,
      bg     = beautiful.xbgpure .. "80",
      widget = wibox.container.background
    },
  top = dpi(8),
  bottom = dpi(8),
  widget = wibox.container.margin
  },
  layout = wibox.layout.stack
}

widget_mew:connect_signal("mouse::enter", function ()
                                 bar_text.visible = true
end)

widget_mew:connect_signal("mouse::leave", function ()
                                 bar_text.visible = false
end)

local function update_widget(used_ram_percentage, available, total)
  ram_bar.value = used_ram_percentage
  bar_text.markup = "<span font=\"".. text_font .. " bold" .."\" \
                           color=\"" ..  beautiful.xforeground .. "\">" .. available .. " / " .. total .. "</span>"
end

local used_ram_script = [[
  bash -c "
  free -m | grep 'Mem:' | awk '{printf \"%d@@%d@##%d##\", $7, $2, $3}'
"]]

awful.widget.watch(used_ram_script, update_interval, function(widget, stdout)
                    local available = stdout:match('(.*)@@')
                    local total = stdout:match('@@(.*)@')
                    local free = stdout:match('##(.*)##')
                    local used_ram_percentage = (total - available) / total * 100
                     
                    if ( used_ram_percentage >= 85 and large_memory_usage_notify == false ) then
                        send_notification("Warning!~",
                                          "A lot of memory is taken: <span color=\"" .. "#ef5350" .. "\">85%</span>   ",
                                          beautiful.xforeground)
                        large_memory_usage_notify = true
                    end

                    if ( used_ram_percentage < 70 ) then
                        large_memory_usage_notify = false
                    end
                     
                    update_widget(used_ram_percentage, free, total)
end)

return widget_mew
