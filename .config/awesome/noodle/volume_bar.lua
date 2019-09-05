-- NOTE:
-- This widget runs a script in the background
-- When awesome restarts, its process will remain alive!
-- Don't worry though! The cleanup script that runs in rc.lua takes care of it :)

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local pad = helpers.pad


local icon_font = "Font Awesome 5 Free Regular 18"
local icon_size = dpi(36)
local progress_bar_width = dpi(215)

-- Set colors
local active_color = beautiful.xcolor1 or "#5AA3CC"
local muted_color = beautiful.volume_bar_muted_color or "#666666"
local active_background_color = beautiful.bar_background or "#222222"
local muted_background_color = beautiful.volume_bar_muted_background_color or "#222222"

local volume_bar = wibox.widget{
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
    background_color = active_background_color,
    border_width  = 0,
    border_color  = beautiful.border_color,
    widget        = wibox.widget.progressbar,
}


local volume_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>")
volume_icon.resize = true
volume_icon.forced_width = icon_size
volume_icon.forced_height = icon_size

volume_bar.forced_width = progress_bar_width

local volume = wibox.widget{
  nil,
  {
    volume_icon,
    pad(1),
    volume_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

-- local function update_widget()
--   awful.spawn.easy_async({"sh", "-c", "pactl list sinks"},
--     function(stdout)
--       local volume = stdout:match('(%d+)%% /')
--       local muted = stdout:match('' .. volume_muted .. ':(%s+)[yes]')
--       local fill_color
--       local bg_color
--       if muted ~= nil then
--         fill_color = muted_color
--         bg_color = muted_background_color
--         volume_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. muted_color .. "\"></span>"
--       else
--         fill_color = active_color
--         bg_color = active_background_color
--         volume_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>"
--       end
--       volume_bar.value = tonumber(volume)
--       volume_bar.color = fill_color
--       volume_bar.background_color = bg_color
--     end
--   )
-- end

local function update_widget()
  awful.spawn.easy_async({"sh", "-c", "pamixer --get-volume --get-mute"},
    function(stdout)
      local volume = stdout:match "%d+"
      local muted = stdout:match "%a+" 
      local fill_color
      local bg_color
      if muted == "true" then
        fill_color = muted_color
        bg_color = muted_background_color
        volume_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. muted_color .. "\"></span>"
      else
        fill_color = active_color
        bg_color = active_background_color
        volume_icon.markup = "<span font=\"".. icon_font .."\" color=\"" .. active_color .. "\"></span>"
      end
      volume_bar.value = tonumber(volume)
      volume_bar.color = fill_color
      volume_bar.background_color = bg_color
    end
  )
end

update_widget()

-- Sleeps until pactl detects an event (volume up/down/toggle mute) аудиоприёмника №0
local volume_script = [[
  bash -c '
  pactl subscribe 0> /dev/null | grep --line-buffered "]] .. volume_sink_name .. [["
  ']]

awful.spawn.with_line_callback(volume_script, {
                                 stdout = function(line)
                                   update_widget()
                                 end
})

return volume
