-- Standard awesome library

local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local theme_collection = {
    "dremora",        -- 1 -- 
  --"whatever",     -- 2 -- 
  -- Add more themes here
}
local config = {
    rules = require("config.rules"),
    keys = require("config.keys"),
}
-- Define context
config.context = { }
local context = config.context

-- Localization
os.setlocale(os.getenv("LANG"))

-- Change this number to use a different theme
local theme_name = theme_collection[1]

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/"
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local helpers = require("helpers")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

local themes = {
    "blackburn",       -- 1
    "copland",         -- 2
    "dremora",         -- 3
    "holo",            -- 4
    "multicolor",      -- 5
    "powerarrow",      -- 6
    "powerarrow-dark", -- 7
    "rainbow",         -- 8
    "steamburn",       -- 9
    "vertex",          -- 10
}

local chosen_theme = themes[5]
-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))


-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
rofi_run = "/home/ranguel/bin/rofr.sh" .. " -r"
rofi_quit = "/home/ranguel/bin/rofr.sh" .. " -l"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}




-- {{{ Key bindings
context.keys = { }
context.keys.modkey           = "Mod4"
context.keys.altkey           = "Mod1"
context.keys.ctrlkey          = "Control"
context.keys.shiftkey         = "Shift"
context.keys.leftkey          = "h"
context.keys.rightkey         = "l"
context.keys.upkey            = "k"
context.keys.downkey          = "j"

context.vars = { }
context.vars.sloppy_focus     = false
context.vars.update_apps      = false
context.vars.terminal         = "urxvtc"
-- context.vars.terminal         = "kitty -1 --listen-on unix:/tmp/_kitty_" .. os.getenv("USER")
context.vars.browser          = "chromium"
context.vars.net_iface        = "wlp58s0"
context.vars.cores            = 2
context.vars.batteries        = { "BAT0" }
context.vars.ac               = "AC"
context.vars.scripts_dir      = os.getenv("HOME") .. "/.bin"
-- context.vars.checkupdate      = "(checkupdates & aur checkupdates) | sed 's/->/→/' | sort | column -t -c 70 -T 2,4"
context.vars.checkupdate      = "checkupdates | sed 's/->/→/' | sort | column -t -c 70 -T 2,4"
-- context.vars.checkupdate      = "checkupdates | sort | column -t -c 70 -T 2,4"

config.keys.init(context)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
config.rules.init(context)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Rounded corners
-- if beautiful.border_radius ~= 0 then
--     client.connect_signal("manage", function (c, startup)
--         if not c.fullscreen then
--             c.shape = helpers.rrect(beautiful.border_radius)
--         end
--     end)

--     -- Make sure fullscreen clients do not have rounded corners
--     client.connect_signal("property::fullscreen", function (c)
--         if c.fullscreen then
--             -- Use delayed_call in order to avoid flickering when corners
--             -- change shape
--             gears.timer.delayed_call(function()
--                 c.shape = helpers.rect()
--             end)
--         else
--             c.shape = helpers.rrect(beautiful.border_radius)
--         end
--     end)

--     client.connect_signal("property::maximize", function (c)
--         if c.fullscreen then
--             -- Use delayed_call in order to avoid flickering when corners
--             -- change shape
--             gears.timer.delayed_call(function()
--                 c.shape = helpers.rect()
--             end)
--         else
--             c.shape = helpers.rrect(beautiful.border_radius)
--         end
--     end)
-- end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

collectgarbage("setpause", 160)
collectgarbage("setstepmul", 400)


-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.width >= 1200 and c.height >= 700 then
            c.border_width = 0
            c.border_color = beautiful.border_normal
        elseif c == 1 or layout == "max" then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
-- for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
--         local clients = awful.client.visible(s)
--         local layout  = awful.layout.getname(awful.layout.get(s))

--         if #clients > 0 then -- Fine grained borders and floaters control
--             for _, c in pairs(clients) do -- Floaters always have borders
--                 if awful.client.floating.get(c) or layout == "floating" then
--                     c.border_width = beautiful.border_width

--                 -- No borders with only one visible client
--                 elseif #clients == 1 or layout == "max" then
--                     clients[1].border_width = 0
--                     awful.client.moveresize(0, 0, 2, 2, clients[1])
--                 else
--                     c.border_width = beautiful.border_width
--                 end
--             end
--         end
--       end)
-- end
-- }}}