-- NOTE:
-- This widget runs a script in the background
-- When awesome restarts, its process will remain alive!
-- Don't worry though! The cleanup script that runs in rc.lua takes care of it :)

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad


-- Set colors
------------------------------------------------------------
local title_color =  beautiful.mpd_song_title_color or beautiful.wibar_fg
local artist_color = beautiful.mpd_song_artist_color or beautiful.wibar_fg
local paused_color = beautiful.mpd_song_paused_color or beautiful.normal_fg
------------------------------------------------------------

local artist_fg
local artist_bg 

-- Control icons
local icon_font_nerd = "Tinos Nerd Font 18"

-- Set notification icon path
local notification_icon = beautiful.music_icon


-- Construct layouts
--------------------------------------------------------------------------------

-- Progressbar
------------------------------------------------------------
local bar_shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, 6)
end

local bar = wibox.widget {
    value         = 64,
    max_value     = 100,
    forced_height = dpi(8),
    forced_width  = dpi(180),
    color     = beautiful.xcolor7,
    background_color = beautiful.xcolor8 .. "33",
    shape         = bar_shape,
    bar_shape   = bar_shape,
    widget        = wibox.widget.progressbar
}

local bar_timer = gears.timer {
    timeout   = 3,
    call_now  = true,
    autostart = true,
    callback  = function()
        awful.spawn.easy_async_with_shell("mpc -f '%time%'", function(stdout)
                bar.value = tonumber(stdout:match('[(]+(%d+)'))
            end
        )
    end
}
------------------------------------------------------------


-- Poster (image)
------------------------------------------------------------
local box_image = wibox.widget.imagebox()
box_image.image = beautiful.music_icon
local image_cont = wibox.widget {
  box_image,
  shape              = bar_shape,
  bg                 = beautiful.xcolor8 .. "33",
  widget             = wibox.container.background
}
------------------------------------------------------------


-- Text lines
------------------------------------------------------------
local mpd_title = wibox.widget.textbox("Title")
local mpd_artist = wibox.widget.textbox("Artist")
mpd_title:set_font(text_font .. " 12")
mpd_title:set_valign("top")
mpd_artist:set_font(text_font .. " medium 14")
mpd_artist:set_valign("top")

local text_area = wibox.layout.fixed.vertical()
text_area:add(wibox.container.constraint(mpd_artist, "exact", nil, dpi(26)))
text_area:add(wibox.container.constraint(mpd_title, "exact", nil, dpi(26)))
------------------------------------------------------------


-- Control line
------------------------------------------------------------
local btn_color = beautiful.xcolor7
-- playback buttons
local player_buttons = wibox.layout.fixed.horizontal()
local prev_button = wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. btn_color .. "\"></span>")
player_buttons:add(wibox.container.margin(prev_button, dpi(0), dpi(0), dpi(6), dpi(6)))

local play_button = wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. btn_color .. "\"></span>")
player_buttons:add(wibox.container.margin(play_button, dpi(14), dpi(14), dpi(6), dpi(6)))

local next_button = wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. btn_color .. "\"></span>")
player_buttons:add(wibox.container.margin(next_button, dpi(0), dpi(0), dpi(6), dpi(6)))
------------------------------------------------------------


-- Full line
local buttons_align = wibox.layout.align.horizontal()
buttons_align:set_expand("outside")
buttons_align:set_middle(player_buttons)

local control_align = wibox.layout.align.horizontal()
control_align:set_middle(buttons_align)
control_align:set_right(nil)
control_align:set_left(nil)
------------------------------------------------------------


-- Bring it all together
------------------------------------------------------------
local align_vertical = wibox.layout.align.vertical()
align_vertical:set_top(text_area)
align_vertical:set_middle(control_align)
align_vertical:set_bottom(wibox.container.constraint(bar, "exact", nil, dpi(8)))
local area = wibox.layout.fixed.horizontal()
area:add(image_cont)
area:add(wibox.container.margin(align_vertical, dpi(10), dpi(10), 0, 0))

local main_wd = wibox.widget {
  area,
  left = dpi(3),
  right = dpi(3),
  forced_width = dpi(200),
  forced_height = dpi(100),
  widget = wibox.container.margin
}
------------------------------------------------------------
--------------------------------------------------------------------------------


-- Buttons
------------------------------------------------------------
bar:buttons(gears.table.join(
                         awful.button({ }, 4, function ()
                             awful.spawn.with_shell("mpc seek +3%")
                             bar_timer:emit_signal("timeout")
                         end),
                         awful.button({ }, 5, function ()
                             awful.spawn.with_shell("mpc seek -3%")
                             bar_timer:emit_signal("timeout")
                         end)
                    )
)
image_cont:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc toggle")
                         end)))
text_area:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc toggle")
                         end)))
play_button:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc toggle")
                         end)))
prev_button:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc prev")
                         end)))
next_button:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc next")
                         end)))
------------------------------------------------------------


-- Notification
------------------------------------------------------------
local last_notification_id
local function send_notification(artist, title, icon)
  notification = naughty.notify({
      title =  artist,
      text = title,
      icon = icon,
      timeout = 4,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end
------------------------------------------------------------


-- Main script
------------------------------------------------------------
local script = [[bash -c '
  IMG_REG="(front|cover|art)\.(jpg|jpeg|png|gif)$"
  DEFAULT_ART="$HOME/.config/awesome/themes/skyfall/icons/music.png"

  file=`mpc current -f %file%`
  info=`mpc -f "%artist%@@%title%@"`
  
  art="$HOME/]] .. music_directory .. [[/${file%/*}"

  if ]] .. "[[ -d $art ]];" .. [[ then
    cover="$(find "$art/" -maxdepth 1 -type f | egrep -i -m1 "$IMG_REG")"
  fi
  cover="${cover:=$DEFAULT_ART}"

  echo $info"##"$cover"##"
']]
------------------------------------------------------------


-- Update widget
------------------------------------------------------------
local function update_widget()
  awful.spawn.easy_async(script,
    function(stdout)

      bar_timer:emit_signal("timeout")

      local artist = stdout:match('(.*)@@')
      local title = stdout:match('@@(.*)@')
      local cover_path = stdout:match('##(.*)##')
      local status = stdout:match('%[(.*)%]')
      status = string.gsub(status, '^%s*(.-)%s*$', '%1')

      local artist_span = "-->   "  .. artist .. "    "
      local title_span = "-->   " .. title .. "    "

      if status == "paused" then
        bar_timer:stop()
        artist_fg = paused_color
        title_fg = paused_color
        play_button.markup = "<span font=\"".. icon_font_nerd .."\" color=\"" .. btn_color .. "\"></span>"
      else
        bar_timer:start()
        artist_fg = artist_color
        title_fg = title_color
        play_button.markup = "<span font=\"".. icon_font_nerd .."\" color=\"" .. btn_color.. "\"></span>"
        if sidebar.visible == false then
          --bar_timer:stop()
          send_notification(artist_span, title_span, cover_path)
        end

      end

      -- Escape &'s
      title = string.gsub(title, "&", "&amp;")
      artist = string.gsub(artist, "&", "&amp;")
      box_image:set_image(cover_path)

      mpd_title.markup =
        "<span foreground='" .. title_fg .."'>"
        .. title .. "</span>"
      mpd_artist.markup =
        "<span foreground='" .. artist_fg .."'>"
        .. artist .. "</span>"

      collectgarbage()
    end
  )
end

update_widget()
------------------------------------------------------------


-- To wait "events" and refresh widget
------------------------------------------------------------
local mpd_script = [[
  bash -c '
    mpc idleloop player
  ']]

awful.spawn.with_line_callback(mpd_script, {
                                 stdout = function(line)
                                   update_widget()
                                 end
})
------------------------------------------------------------


return main_wd
