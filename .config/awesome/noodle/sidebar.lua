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
local icon_font_nerd = "Tinos Nerd Font 18"
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
local weather_widget = require("noodle.weather")
local weather_widget_icon = weather_widget:get_all_children()[1]
weather_widget_icon.forced_width = dpi(30)
weather_widget_icon.forced_height = icon_size
local weather_widget_text = weather_widget:get_all_children()[2]
weather_widget_text.font = text_font .. " medium 16"

-- Dummy weather_widget for testing
-- (avoid making requests with every awesome restart)
-- local weather_widget = wibox.widget.textbox("[i] bla bla bla!")

local weather = wibox.widget{
    nil,
    weather_widget,
    nil,
    layout = wibox.layout.align.horizontal,
    expand = "none"
}
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
local battery_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor6 .. "\"></span>")
battery_icon.resize = true
battery_icon.forced_width = icon_size
battery_icon.forced_height = icon_size
awesome.connect_signal(
  "charger_plugged", function(c)
    battery_icon.image = beautiful.battery_charging_icon
end)
awesome.connect_signal(
  "charger_unplugged", function(c)
    battery_icon.image = beautiful.battery_icon
end)
local battery_bar = require("noodle.battery_bar")
battery_bar.forced_width = progress_bar_width
-- battery_bar.margins.top = progress_bar_margins
-- battery_bar.margins.bottom = progress_bar_margins
local battery = wibox.widget{
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
local disk_space = require("noodle.disk")
disk_space.font = text_font .. " medium 14"
local disk_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_nerd .."\" color=\"" .. beautiful.xcolor7 .. "\"></span>")
disk_icon.resize = true
disk_icon.forced_width = dpi(30)
disk_icon.forced_height = icon_size
local disk = wibox.widget{
  nil,
  {
    disk_icon,
    disk_space,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

disk:buttons(gears.table.join(
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
    update_icon,
    pad(1),
    updates,
    layout = wibox.layout.fixed.horizontal
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.horizontal
}

updates_widget:buttons(gears.table.join(
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
local volume_icon = 
        wibox.widget.textbox("<span font=\"".. icon_font_small .."\" color=\"" .. beautiful.xcolor7 .. "\"></span>")
volume_icon.resize = true
volume_icon.forced_width = icon_size
volume_icon.forced_height = icon_size
local volume_bar = require("noodle.volume_bar")
volume_bar.forced_width = progress_bar_width
-- volume_bar.shape = gears.shape.circle
-- volume_bar.margins.top = progress_bar_margins
-- volume_bar.margins.bottom = progress_bar_margins
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


-------------------------------------------------------------------------------------------------------------
-- Create the sidebar  --------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
sidebar = wibox({x = 0, y = 0, visible = false, ontop = true, type = "dock"})
sidebar.bg = beautiful.sidebar_bg or beautiful.wibar_bg or "#111111"
sidebar.fg = beautiful.sidebar_fg or beautiful.wibar_fg or "#FFFFFF"
sidebar.opacity = beautiful.sidebar_opacity or 1
sidebar.height = beautiful.sidebar_height or awful.screen.focused().geometry.height
sidebar.width = beautiful.sidebar_width or dpi(300)
sidebar.y = beautiful.sidebar_y or 0
local radius = beautiful.sidebar_border_radius or 0
if beautiful.sidebar_position == "right" then
  sidebar.x = awful.screen.focused().geometry.width - sidebar.width
  sidebar.shape = helpers.prrect(radius, true, false, false, true)
else
  sidebar.x = beautiful.sidebar_x or 0
  sidebar.shape = helpers.prrect(radius, false, true, true, false)
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
                           sidebar.visible = false
  end)
end
-- Activate sidebar by moving the mouse at the edge of the screen
if beautiful.sidebar_hide_on_mouse_leave then
  local sidebar_activator = wibox({y = sidebar.y, width = 1, visible = true, ontop = false, opacity = 0, below = true})
  sidebar_activator.height = sidebar.height
  -- sidebar_activator.height = sidebar.height - beautiful.wibar_height
  sidebar_activator:connect_signal("mouse::enter", function ()
                                     sidebar.visible = true
  end)

  if beautiful.sidebar_position == "right" then
    sidebar_activator.x = awful.screen.focused().geometry.width - sidebar_activator.width
  else
    sidebar_activator.x = 0
  end

  sidebar_activator:buttons(
    gears.table.join(
      -- awful.button({ }, 2, function ()
      --     start_screen_show()
      --     -- sidebar.visible = not sidebar.visible
      -- end),
      awful.button({ }, 4, function ()
          awful.tag.viewprev()
      end),
      awful.button({ }, 5, function ()
          awful.tag.viewnext()
      end)
  ))
end

-- Item placement
sidebar:setup {
  { ----------- TOP GROUP -----------
    -- pad(1),
    pad(1),
    time,
    date,
    -- pad(1),
    weather,
    --pad(1),
    --pad(1),
    layout = wibox.layout.fixed.vertical
  },
  { ----------- MIDDLE GROUP -----------
    {
      -- Put some padding at the left and right edge so that
      pad(2),
      {
        mpd_song,
        top = dpi(24),
        bottom = dpi(24),
        widget = wibox.container.margin
      },
      pad(2),
      layout = wibox.layout.align.horizontal,
    },
    --pad(1),
    --pad(1),
    volume,
    cpu,
    ram,
    temperature,
    brightness,
    battery,
    --pad(1),
    {
      updates_widget,
      top = dpi(14),
      bottom = dpi(14),
      widget = wibox.container.margin
    },
    --pad(1),
    network,
    pad(1),
    -- updates_widget,
    layout = wibox.layout.fixed.vertical
  },
  { ----------- BOTTOM GROUP -----------
    -- {
    --   updates_widget,
    --   pad(1),
    --   layout = wibox.layout.fixed.vertical
    -- },
    { -- Search and exit screen
      nil,
      {
        search,
        pad(5),
        exit,
        pad(2),
        layout = wibox.layout.fixed.horizontal
      },
      nil,
      layout = wibox.layout.align.horizontal,
      expand = "none"
    },
    pad(1),
    layout = wibox.layout.fixed.vertical
  },
  layout = wibox.layout.align.vertical,
  -- expand = "none"
}
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------