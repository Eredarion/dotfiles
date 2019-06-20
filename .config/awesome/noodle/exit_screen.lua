local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")
local pad = helpers.pad
local keygrabber = require("awful.keygrabber")

-- Appearance
local icon_size = beautiful.exit_screen_icon_size or 140
local text_font = beautiful.exit_screen_font or "sans 14"

-- Commands
local poweroff_command = function()
  awful.spawn.with_shell("poweroff")
  awful.keygrabber.stop(exit_screen_grabber)
end
local reboot_command = function()
  awful.spawn.with_shell("reboot")
  awful.keygrabber.stop(exit_screen_grabber)
end
local suspend_command = function()
  awful.spawn.with_shell("systemctl suspend")
  -- awful.spawn.with_shell("i3lock & systemctl suspend")
  exit_screen_hide()
end
local exit_command = function()
  awesome.quit()
end
local lock_command = function()
  awful.spawn.with_shell("i3lock")
  exit_screen_hide()
end

local username = os.getenv("USER")
-- Capitalize username
local goodbye_widget = wibox.widget.textbox("Goodbye " .. username:sub(1,1):upper()..username:sub(2))
goodbye_widget.font = "sans 70"

local poweroff_icon = wibox.widget.imagebox(beautiful.poweroff_icon)
poweroff_icon.resize = true
poweroff_icon.forced_width = icon_size
poweroff_icon.forced_height = icon_size
local poweroff_text = wibox.widget.textbox("Poweroff")
poweroff_text.font = text_font

local poweroff = wibox.widget{
  {
    nil,
    poweroff_icon,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  {
    pad(1),
    poweroff_text,
    pad(1),
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  -- forced_width = 100,
  layout = wibox.layout.fixed.vertical
}
poweroff:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                     poweroff_command()
                 end)
))

local reboot_icon = wibox.widget.imagebox(beautiful.reboot_icon)
reboot_icon.resize = true
reboot_icon.forced_width = icon_size
reboot_icon.forced_height = icon_size
local reboot_text = wibox.widget.textbox("Reboot")
reboot_text.font = text_font

local reboot = wibox.widget{
  {
    nil,
    reboot_icon,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  {
    nil,
    reboot_text,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  -- forced_width = 100,
  layout = wibox.layout.fixed.vertical
}
reboot:buttons(gears.table.join(
                   awful.button({ }, 1, function ()
                       reboot_command()
                   end)
))

local suspend_icon = wibox.widget.imagebox(beautiful.suspend_icon)
suspend_icon.resize = true
suspend_icon.forced_width = icon_size
suspend_icon.forced_height = icon_size
local suspend_text = wibox.widget.textbox("Suspend")
suspend_text.font = text_font

local suspend = wibox.widget{
  {
    nil,
    suspend_icon,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  {
    nil,
    suspend_text,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  -- forced_width = 100,
  layout = wibox.layout.fixed.vertical
}
suspend:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                     suspend_command()
                 end)
))


local exit_icon = wibox.widget.imagebox(beautiful.exit_icon)
exit_icon.resize = true
exit_icon.forced_width = icon_size
exit_icon.forced_height = icon_size
local exit_text = wibox.widget.textbox("Exit")
exit_text.font = text_font

local exit = wibox.widget{
  {
    nil,
    exit_icon,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  {
    nil,
    exit_text,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  -- forced_width = 100,
  layout = wibox.layout.fixed.vertical
}
exit:buttons(gears.table.join(
                  awful.button({ }, 1, function ()
                      exit_command()
                  end)
))

local lock_icon = wibox.widget.imagebox(beautiful.lock_icon)
lock_icon.resize = true
lock_icon.forced_width = icon_size
lock_icon.forced_height = icon_size
local lock_text = wibox.widget.textbox("Lock")
lock_text.font = text_font

local lock = wibox.widget{
  {
    nil,
    lock_icon,
    nil,
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  {
    pad(1),
    lock_text,
    pad(1),
    expand = "none",
    layout = wibox.layout.align.horizontal
  },
  -- forced_width = 100,
  layout = wibox.layout.fixed.vertical
}
lock:buttons(gears.table.join(
                   awful.button({ }, 1, function ()
                       lock_command()
                   end)
))

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

-- Create the widget
exit_screen = wibox({x = 0, y = 0, visible = false, ontop = true, type = "dock", height = screen_height, width = screen_width})

exit_screen.bg = beautiful.exit_screen_bg or beautiful.wibar_bg or "#111111"
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or "#FEFEFE"

-- Create an container box
-- local exit_screen_box = wibox.container.background()
-- exit_screen_box.bg = exit_screen.bg
-- exit_screen_box.shape = gears.shape.rounded_rect
-- exit_screen_box.shape_border_radius = 20

local exit_screen_grabber
function exit_screen_hide()
  awful.keygrabber.stop(exit_screen_grabber)
  exit_screen.visible = false
end
function exit_screen_show()
  exit_screen_grabber = awful.keygrabber.run(function(_, key, event)
      if event == "release" then return end

      if     key == 's'    then
        suspend_command()
      -- 'e' for exit
      elseif key == 'e'    then
        exit_command()
      elseif key == 'l'    then
        lock_command()
      elseif key == 'p'    then
        poweroff_command()
      elseif key == 'r'    then
        reboot_command()
      elseif key == 'Escape' or key == 'q' or key == 'x' then
        exit_screen_hide()
      -- else awful.keygrabber.stop(exit_screen_grabber)
      end
  end)
  exit_screen.visible = true
end

exit_screen:buttons(gears.table.join(
                 -- Middle click - Hide exit_screen
                 awful.button({ }, 2, function ()
                     exit_screen_hide()
                 end),
                 -- Right click - Hide exit_screen
                 awful.button({ }, 3, function ()
                     exit_screen_hide()
                 end)
))

-- Item placement
exit_screen:setup {
  nil,
  {
    {
      nil,
      goodbye_widget,
      nil,
      expand = "none",
      layout = wibox.layout.align.horizontal
    },
    {
      nil,
      {
        -- {
          poweroff,
          pad(3),
          reboot,
          pad(3),
          suspend,
          pad(3),
          exit,
          pad(3),
          lock,
          layout = wibox.layout.fixed.horizontal
        -- },
        -- widget = exit_screen_box
      },
      nil,
      expand = "none",
      layout = wibox.layout.align.horizontal
      -- layout = wibox.layout.fixed.horizontal
    },
    layout = wibox.layout.fixed.vertical
  },
  nil,
  expand = "none",
  layout = wibox.layout.align.vertical
}
