local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad

-- Icon font ------------------------------------------------------------------------------------------------
local icon_font = "Font Awesome 5 Free Regular 24"
local icon_font_small = "Font Awesome 5 Free Regular 18"
local icon_font_nerd = "Tinos Nerd Font 20"
local icon_font_big = "Font Awesome 5 Free Bold 30" 
local icon_font_tiny = "Font Awesome 5 Free Regular 15"
-------------------------------------------------------------------------------------------------------------


-- Some commonly used variables -----------------------------------------------------------------------------
local playerctl_button_size = dpi(36)
local playerctl_button_size_big = dpi(42)
local icon_size = dpi(36)
local progress_bar_width = dpi(215)
-- local progress_bar_margins = dpi(9)
-------------------------------------------------------------------------------------------------------------


-- Notification ---------------------------------------------------------------------------------------------
local last_notification_id
local function send_notification(title, text, icon)
  notification = naughty.notify({
      title =  title,
      text = text,
      icon = icon,
      timeout = 4,
      replaces_id = last_notification_id
  })
  last_notification_id = notification.id
end
-------------------------------------------------------------------------------------------------------------


-- Bar shape ------------------------------------------------------------------------------------------------
bar_shape = function(cr, width, height)
  gears.shape.parallelogram(cr, width, height, width-10)
end
-------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------
-- Item configuration ---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-- Exit widget ----------------------------------------------------------------------------------------------
local exit_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor1 .. "\"></span>")
exit_icon.resize = true
exit_icon.forced_width = icon_size
exit_icon.forced_height = icon_size
local exit_text = wibox.widget.textbox("Exit")
exit_text.font = text_font .. " medium 14"

local exit = wibox.widget{
  exit_icon,
  exit_text,
  layout = wibox.layout.fixed.horizontal
}
exit:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                     exit_screen_show()
                     sidebar.visible = false
                 end)
))
-------------------------------------------------------------------------------------------------------------


-- Weather widget -------------------------------------------------------------------------------------------
-- local weather_widget = require("noodle.weather")
-- local weather_widget_icon = weather_widget:get_all_children()[1]
-- weather_widget_icon.forced_width = dpi(30)
-- weather_widget_icon.forced_height = icon_size
-- local weather_widget_text = weather_widget:get_all_children()[2]
-- weather_widget_text.font = text_font .. " medium 16"

-- -- Dummy weather_widget for testing
-- -- (avoid making requests with every awesome restart)
-- -- local weather_widget = wibox.widget.textbox("[i] bla bla bla!")

-- local weather = wibox.widget{
--     nil,
--     weather_widget,
--     nil,
--     layout = wibox.layout.align.horizontal,
--     expand = "none"
-- }
-------------------------------------------------------------------------------------------------------------


-- Brightness widget ----------------------------------------------------------------------------------------
local brightness_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. beautiful.xcolor5 .. "\"></span>")
brightness_icon.resize = true
brightness_icon.forced_width = icon_size
brightness_icon.forced_height = icon_size
local brightness_bar = require("noodle.brightness_bar")
brightness_bar.forced_width = progress_bar_width
local brightness = wibox.widget{
  nil,
  {
    brightness_icon,
    pad(1),
    brightness_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}
brightness:buttons(
  gears.table.join(
    -- Left click - Toggle redshift
    awful.button({ }, 1, function ()
        awful.spawn.easy_async_with_shell("xbacklight -set 20", function()
            awesome.emit_signal("brightness_changed")
        end)
    end),
    -- Right click - Reset brightness (Set to max)
    awful.button({ }, 3, function ()
        awful.spawn.easy_async_with_shell("xbacklight -set 100", function()
            awesome.emit_signal("brightness_changed")
        end)
    end),
    -- Scroll up - Increase brightness
    awful.button({ }, 4, function ()
        awful.spawn.easy_async_with_shell("xbacklight -inc 10", function()
            awesome.emit_signal("brightness_changed")
        end)
    end),
    -- Scroll down - Decrease brightness
    awful.button({ }, 5, function ()
        awful.spawn.easy_async_with_shell("xbacklight -dec 10", function()
            awesome.emit_signal("brightness_changed")
        end)
    end)
))
-------------------------------------------------------------------------------------------------------------


-- Temperature widget ---------------------------------------------------------------------------------------
local temperature_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor4 .. "\"></span>")
temperature_icon.resize = true
temperature_icon.forced_width = icon_size
temperature_icon.forced_height = icon_size
local temperature_bar = require("noodle.temperature_bar")
temperature_bar.forced_width = progress_bar_width
local temperature_bar_text = temperature_bar:get_all_children()[2]:get_all_children()[1]
-- temperature_bar.margins.top = progress_bar_margins
-- temperature_bar.margins.bottom = progress_bar_margins
local temperature = wibox.widget{
  nil,
  {
    temperature_icon,
    pad(1),
    temperature_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}
temperature:buttons(
  gears.table.join(
    awful.button({ }, 1, function ()
        -- local matcher = function (c)
        --   return awful.rules.match(c, {name = 'watch sensors'})
        -- end
        -- awful.client.run_or_raise(terminal .." -e 'watch sensors'", matcher)
        -- awful.spawn(terminal .. " -e 'watch sensors'", {floating = true})
        awful.spawn.easy_async([[bash -c "temp_level=`sensors | grep Package | awk '{print $4}'`
                                         echo $temp_level"]], function(stdout)
          send_notification("Temperature   ",
                            "CPU temperature: <span color=\"" .. "#FF6FC4" .. "\">" .. stdout:gsub("%s+", "") .. "</span>",
                            beautiful.temperature_icon)
        end) 
    end)
))
-------------------------------------------------------------------------------------------------------------


-- Battery widget -------------------------------------------------------------------------------------------
battery = require("noodle.battery_bar")

local script_Bt = [[bash -c "
  battery_level=`upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}'`
  battery_status=`upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}'`
  echo $battery_level"@@"$battery_status"@"
"]]

battery:buttons(
  gears.table.join(
    awful.button({ }, 1, function ()
        awful.spawn.easy_async(script_Bt, function(stdout)
          local batlevel = stdout:match('(.*)@@')
          local batstatus = stdout:match('@@(.*)@')
          send_notification("Battery   ",
                            "Level: <span color=\"" .. "#A7A5EE" .. "\">" .. batlevel .. "</span>   \n" ..
                            "Status: <span color=\"" .. "#A7A5EE" .. "\">" .. batstatus .. "</span>   ",
                            beautiful.battery_icon)
        end)    
    end)
))
-------------------------------------------------------------------------------------------------------------


-- Cpu widget -----------------------------------------------------------------------------------------------
local cpu_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor2 .. "\"></span>")
cpu_icon.resize = true
cpu_icon.forced_width = icon_size
cpu_icon.forced_height = icon_size
local cpu_bar = require("noodle.cpu_bar")
cpu_bar.forced_width = progress_bar_width
-- cpu_bar.margins.top = progress_bar_margins
-- cpu_bar.margins.bottom = progress_bar_margins
local cpu = wibox.widget{
  nil,
  {
    cpu_icon,
    pad(1),
    cpu_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

cpu:buttons(
  gears.table.join(
    awful.button({ }, 1, function ()
        local matcher = function (c)
          return awful.rules.match(c, {name = 'htop'})
        end
        awful.client.run_or_raise(terminal .. " -e htop", matcher)
    end),
    awful.button({ }, 3, function ()
        local matcher = function (c)
          return awful.rules.match(c, {name = 'xfce4-taskmanager'})
        end
        awful.client.run_or_raise("xfce4-taskmanager", matcher)
    end)
))
-------------------------------------------------------------------------------------------------------------


-- Ram widget -----------------------------------------------------------------------------------------------
local ram_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_tiny .."\" color=\"" .. beautiful.xcolor3 .. "\"></span>")
ram_icon.resize = true
ram_icon.forced_width = icon_size
ram_icon.forced_height = icon_size
local ram_bar = require("noodle.ram_bar")
ram_bar.forced_width = progress_bar_width
local ram_bar_text = ram_bar:get_all_children()[2]:get_all_children()[1]

-- ram_bar.margins.top = progress_bar_margins
-- ram_bar.margins.bottom = progress_bar_margins
local ram = wibox.widget{
  nil,
  {
    ram_icon,
    pad(1),
    ram_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

ram:buttons(
  gears.table.join(
    awful.button({ }, 1, function ()
        local matcher = function (c)
          return awful.rules.match(c, {name = 'htop'})
        end
        awful.client.run_or_raise(terminal .. " " .. terminal_geometry .. " -e  htop --sort-key PERCENT_MEM", matcher)
    end),
    awful.button({ }, 3, function ()
        local matcher = function (c)
          return awful.rules.match(c, {class = 'xfce4-taskmanager'})
        end
        awful.client.run_or_raise("xfce4-taskmanager", matcher)
    end)
))
-------------------------------------------------------------------------------------------------------------


-- Mpd widget -----------------------------------------------------------------------------------------------
local mpd_song = require("noodle.mpd_song")
-------------------------------------------------------------------------------------------------------------


-- Time and Data widget -------------------------------------------------------------------------------------
local time = wibox.widget.textclock("%H:%M")
time.align = "center"
time.valign = "center"
time.font = text_font .. " 64"

local date = wibox.widget.textclock("%A %d %B")
-- local date = wibox.widget.textclock("%A, %B %d")
-- local date = wibox.widget.textclock("%A, %B %d, %Y")
date.align = "center"
date.valign = "center"
date.font = text_font .. " medium 20"
-------------------------------------------------------------------------------------------------------------


-- Disk space widget ----------------------------------------------------------------------------------------
local disk_bar_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. beautiful.xcolor6 .. "\"></span>")
disk_bar_icon.resize = true
disk_bar_icon.forced_width = icon_size + 7
disk_bar_icon.forced_height = icon_size 
local disk_bar = require("noodle.disk_bar")
disk_bar.forced_width = progress_bar_width
local disk_bar_text = disk_bar:get_all_children()[2]:get_all_children()[1]

local disk_bar_widget = wibox.widget{
  nil,
  {
    disk_bar_icon,
    -- pad(1),
    disk_bar,
    pad(1),
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

disk_bar_widget:buttons(gears.table.join(
                       awful.button({ }, 1, function ()
                           awful.spawn(filemanager, {floating = true})
                       end),
                       awful.button({ }, 3, function ()
                           awful.spawn(filemanager .. " /data", {floating = true})
                       end)
))
-------------------------------------------------------------------------------------------------------------


-- Search widget --------------------------------------------------------------------------------------------
local search_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor1 .. "\"></span>")
search_icon.resize = true
search_icon.forced_width = icon_size
search_icon.forced_height = icon_size
local search_text = wibox.widget.textbox("Search")
search_text.font = text_font .. " medium 14"

local search = wibox.widget{
  search_icon,
  search_text,
  layout = wibox.layout.fixed.horizontal
}
search:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                     awful.spawn.with_shell(rofi_script)
                     sidebar.visible = false
                 end),
                 awful.button({ }, 3, function ()
                     awful.spawn.with_shell("rofi -show combi")
                     sidebar.visible = false
                 end)
))
-------------------------------------------------------------------------------------------------------------


-- Updates --------------------------------------------------------------------------------------------------
local updates = require("noodle.pacman_pkg")
updates.font = text_font .. " medium 14"

local update_icon = wibox.widget.imagebox(beautiful.update_icon)
update_icon.resize = true
update_icon.forced_width = dpi(38)
update_icon.forced_height = dpi(38)

local updates_widget = wibox.widget{
  nil,
  {
    -- update_icon,
    -- pad(1),
    updates,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

updates:buttons(gears.table.join(
                awful.button({ }, 1, function ()
                    local matcher = function (c)
                      return awful.rules.match(c, {name = 'upd'})
                    end
                    awful.client.run_or_raise("pacman_update " .. terminal, matcher)
                    sidebar.visible = false
                end),
                awful.button({ }, 3, function ()
                    awesome.emit_signal("pacman_upd")
                end)
))
-------------------------------------------------------------------------------------------------------------


-- Volume widget --------------------------------------------------------------------------------------------
local volume = require("noodle.volume_bar")

volume:buttons(gears.table.join(
                 -- Left click - Mute / Unmute
                 awful.button({ }, 1, function ()
                     awful.spawn.with_shell("pamixer -t")
                 end),
                 -- Right click - Run or raise pavucontrol
                 awful.button({ }, 3, function () 
                     local matcher = function (c)
                       return awful.rules.match(c, {class = 'Pavucontrol'})
                     end
                     awful.client.run_or_raise("pavucontrol", matcher)
                 end),
                 -- Scroll - Increase / Decrease volume
                 awful.button({ }, 4, function () 
                     awful.spawn.with_shell("pamixer -i 5")
                 end),
                 awful.button({ }, 5, function () 
                     awful.spawn.with_shell("pamixer -d 5")
                 end)
))
-------------------------------------------------------------------------------------------------------------


-- Net ------------------------------------------------------------------------------------------------------
local network_wd = require("noodle.network")

local network = wibox.widget{
  nil,
  {
    pad(3),
    network_wd,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------


-- Area -----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-- Mpd area -------------------------------------------------------------------------------------------------
local mpd_area = wibox.layout.align.vertical()
mpd_area:set_top(nil)
mpd_area:set_middle(wibox.container.margin(mpd_song, dpi(14), dpi(10), 0, 0))
mpd_area:set_bottom(nil)
-------------------------------------------------------------------------------------------------------------


-- System info area -----------------------------------------------------------------------------------------
local sys_info_area = wibox.layout.fixed.vertical()
sys_info_area:add(volume)
sys_info_area:add(cpu)
sys_info_area:add(ram)
sys_info_area:add(temperature)
sys_info_area:add(brightness)
sys_info_area:add(disk_bar_widget)
sys_info_area:add(battery)
-------------------------------------------------------------------------------------------------------------


-- User info area -------------------------------------------------------------------------------------------
local user_text = wibox.widget.textbox()
user_text.font = text_font .. " medium 14"

local username = os.getenv("USER")
awful.spawn.easy_async_with_shell("hostname", function(out)
    -- Remove trailing whitespaces
    out = out:gsub('^%s*(.-)%s*$', '%1')
    user_text.markup = helpers.colorize_text(username.."@"..out, beautiful.xcolor7)
end)

local kernel_text = wibox.widget.textbox()
kernel_text.font = text_font .. " medium 14"
awful.spawn.easy_async_with_shell("uname -r | cut -d '-' -f1", function(out)
    -- Remove trailing whitespaces
    kernel_text.markup = helpers.colorize_text("Kernel: " .. out, beautiful.xcolor7)
end)


local user_info_area = wibox.layout.align.vertical()
user_info_area:set_top(wibox.container.constraint(user_text, "exact", nil, dpi(26)))
user_info_area:set_middle(wibox.container.constraint(kernel_text, "exact", nil, dpi(26)))
user_info_area:set_bottom(updates)

local user_picture_container = wibox.container.background()
user_picture_container.shape = gears.shape.circle
-- user_picture_container.shape = helpers.prrect(30, true, true, false, true)
user_picture_container.forced_height = dpi(100)
user_picture_container.forced_width = dpi(100)
local user_picture = wibox.widget {
    wibox.widget.imagebox(os.getenv("HOME").."/.config/awesome/profile.png"),
    widget = user_picture_container
}


local user_area = wibox.layout.fixed.horizontal()
--user_area:add(wibox.container.margin(user_picture, dpi(14), dpi(14), 0, 0))
--user_area:add(wibox.container.margin(user_info_area, dpi(10), dpi(10), 0, 0))
user_area:add(wibox.container.margin(user_picture, dpi(14), dpi(14), 0, 0))
user_area:add(user_info_area)
-------------------------------------------------------------------------------------------------------------


-- Network and button area ----------------------------------------------------------------------------------
local btn_area = wibox.layout.fixed.horizontal()
btn_area:add(search)
btn_area:add(pad(5))
btn_area:add(exit)
btn_area:add(pad(2))

local btn_align = wibox.layout.align.horizontal()
btn_align:set_expand("none")
btn_align:set_middle(btn_area)
btn_align:set_right(nil)
btn_align:set_left(nil)

local bottom_area = wibox.layout.fixed.vertical()
bottom_area:add(wibox.container.margin(network, dpi(0), dpi(0), dpi(13), dpi(22)))
bottom_area:add(btn_align)
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height
local wi_bg = beautiful.xbackground
local margin = beautiful.useless_gap + beautiful.screen_margin
-- local free_screen_height = screen_height - beautiful.wibar_height - margin * 5
local free_screen_height = screen_height - beautiful.wibar_height - margin * 7

local vis = false

function round(number)
  if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
    number = number - (number % 1)
  else
    number = (number - (number % 1)) + 1
  end
 return number
end


-------------------------------------------------------------------------------------------------------------
-- Create the sidebar  --------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
local notyfi_shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, 6)
end

local sidebar_shape = function(cr, width, height)
  gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 6)
end

local border_color = beautiful.xforeground
local container_border_color = beautiful.xforeground

sidebar = wibox({x = 0, y = 0, visible = false, ontop = true, type = "dock", screen = 1 })
sidebar.bg = beautiful.xbackgroundtp or beautiful.wibar_bg or "#111111"
sidebar.fg = beautiful.sidebar_fg or beautiful.wibar_fg or "#FFFFFF"
sidebar.opacity = beautiful.sidebar_opacity or 1
-- sidebar.border_width = dpi(1)
-- sidebar.border_color = border_color
sidebar.height = beautiful.sidebar_height - beautiful.wibar_height - margin * 2 or awful.screen.focused().geometry.height
sidebar.width = beautiful.sidebar_width + margin * 2 or dpi(300)
sidebar.y = beautiful.wibar_height + margin
local radius = beautiful.sidebar_border_radius or 0
if beautiful.sidebar_position == "right" then
  sidebar.x = awful.screen.focused().geometry.width - sidebar.width
  sidebar.shape = helpers.prrect(radius, true, false, false, true)
else
  sidebar.x = beautiful.sidebar_x or 0
  sidebar.shape = sidebar_shape
end
-- sidebar.shape = helpers.rrect(radius)

sidebar:buttons(gears.table.join(
                  -- Middle click - Hide sidebar
                  awful.button({ }, 2, function ()
                      sidebar.visible = false
                  end)
                  -- Right click - Hide sidebar
                  -- awful.button({ }, 3, function ()
                  --     sidebar.visible = false
                  --     -- mymainmenu:show()
                  -- end)
))

-- Hide sidebar when mouse leaves
if beautiful.sidebar_hide_on_mouse_leave then
  sidebar:connect_signal("mouse::leave", function ()
          if (sidebar.visible) then
              sidebar.visible = false
          end
  end)
end
-- Activate sidebar by moving the mouse at the edge of the screen
-- if beautiful.sidebar_hide_on_mouse_leave then
--   local sidebar_activator = wibox({y = sidebar.y, width = 1, visible = true, ontop = false, opacity = 0, below = true})
--   sidebar_activator.height = sidebar.height
--   -- sidebar_activator.height = sidebar.height - beautiful.wibar_height
--   sidebar_activator:connect_signal("mouse::enter", function ()
--                             --sidebar.visible = true
--       -- time_date_wibox.visible = true
--       -- mpd_wibox.visible = true
--       -- sys_info_wibox.visible = true
--       -- bottom_wibox.visible = true
--   end)

--   if beautiful.sidebar_position == "right" then
--     sidebar_activator.x = awful.screen.focused().geometry.width - sidebar_activator.width
--   else
--     sidebar_activator.x = 0
--   end

--   sidebar_activator:buttons(
--     gears.table.join(
--       -- awful.button({ }, 2, function ()
--       --     start_screen_show()
--       --     -- sidebar.visible = not sidebar.visible
--       -- end),
--       awful.button({ }, 4, function ()
--           awful.tag.viewprev()
--       end),
--       awful.button({ }, 5, function ()
--           awful.tag.viewnext()
--       end)
--   ))
-- end

check_text_bars_visible = function()
  if (ram_bar_text.visible == true) then
    ram_bar_text.visible = false
  end

  if (temperature_bar_text.visible == true) then
    temperature_bar_text.visible = false
  end

  if (disk_bar_text.visible == true) then
    disk_bar_text.visible = false
  end

end

awesome.connect_signal("hide_bar_hover", function ()
                  ram_bar_text.visible = false
                  temperature_bar_text.visible = false
                  disk_bar_text.visible = false
end)

-- rectangle
local container = function(widget, shape_border_color, margin_bot, margin_left, height)
  return {
      {
        {
          nil,
          widget,
          nil,
          expand = "none",
          layout = wibox.layout.align.vertical
        },
        forced_height = round(height),
        shape = notyfi_shape,
        shape_border_width = dpi(0),
        shape_border_color = container_border_color,
        bg = beautiful.xbackground .. "A6",
        widget = wibox.container.background
      },
      left = margin,
      right = margin,
      --bottom = margin_bot,
      widget = wibox.container.margin,
    }
end


local space = function(height)
  return {
      forced_height = height,
      widget = wibox.widget.textbox
    }
end


-- Item placement
sidebar:setup {
    --space(beautiful.wibar_height + margin),
    space(margin),
    container(user_area, beautiful.xcolor1, 0, 0, free_screen_height * 0.18),
    space(margin),
    container(mpd_area, beautiful.xcolor2, 0, 0, free_screen_height * 0.19),
    space(margin),
    container(sys_info_area, beautiful.xcolor3, 0, 0, free_screen_height * 0.41),
    space(margin),
    container(bottom_area, beautiful.xcolor5, margin, 0, free_screen_height * 0.22),
    space(margin),
  layout = wibox.layout.fixed.vertical
  -- expand = "none"
}
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
