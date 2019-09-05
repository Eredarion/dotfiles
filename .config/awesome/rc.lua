--[[
    ___       ___       ___       ___       ___       ___       ___
   /\  \     /\__\     /\  \     /\  \     /\  \     /\__\     /\  \
  /::\  \   /:/\__\   /::\  \   /::\  \   /::\  \   /::L_L_   /::\  \
 /::\:\__\ /:/:/\__\ /::\:\__\ /\:\:\__\ /:/\:\__\ /:/L:\__\ /::\:\__\
 \/\::/  / \::/:/  / \:\:\/  / \:\:\/__/ \:\/:/  / \/_/:/  / \:\:\/  /
   /:/  /   \::/  /   \:\/  /   \::/  /   \::/  /    /:/  /   \:\/  /
   \/__/     \/__/     \/__/     \/__/     \/__/     \/__/     \/__/

--]]

local theme_collection = {
    "manta",        -- 1 --
    "lovelace",     -- 2 --
    "skyfall",      -- 3 --
}

-- Change this number to use a different theme
local theme_name = theme_collection[3]

----------------------------------------------

local bar_theme_collection = {
    "manta",        -- 1 -- Taglist, client counter, date, time, layout
    "lovelace",     -- 2 -- Start button, taglist, layout
    "skyfall",      -- 3 -- Weather, taglist, window buttons, pop-up tray
}

-- Change this number to use a different bar theme
local bar_theme_name = bar_theme_collection[3]

--------------------------------------------------------------------------------

-- Theme handling library
local beautiful = require("beautiful")
-- Themes define colours, icons, font and wallpapers.
local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/"
beautiful.init( theme_dir .. theme_name .. "/theme.lua" )
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Default notification library
local naughty = require("naughty")
local menubar = require("menubar")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi


local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")

-- ~~ Noodle Cleanup Script ~~
-- Some of my widgets (mpd, volume) rely on scripts that have to be
-- run persistently in the background.
-- They sleep until mpd/volume state changes, in an infinite loop.
-- As a result when awesome restarts, they keep running in background, along with the new ones that are created after the restart.
-- This script cleans up the old processes.
awful.spawn.with_shell("~/.config/awesome/awesome-cleanup.sh")

-------------------------------------------------------------------------------------------------------------
-- Initialize stuff -----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

--  Widget variables ----------------------------------------------------------------------------------------
-- Look in the terminal (command - df)
root_disk = "/dev/sda7"

-- Look in the terminal (command - pactl list sinks). May not need to change anything.
-- (your shell language) default: russian:"аудиоприёмника №0" english:"sink #0"
volume_sink_name="аудиоприёмника №1"
-- Need for parse (your shell language) russian:"Звук выключен" english:"Mute"
volume_muted="Звук выключен"

-- Your music directory name. Need for search cover. For example my ~/Music
-- Search front/cover/art.jpg/jpeg/png/gif files
music_directory="Music"

-- Weather widget сonfiguration
-- Get your key and find your city id at https://openweathermap.org/
-- You will need to make an account!
api_key = "075f3847543e881a3e781ed924d9d114"
city_id = "707928"

-------------------------------------------------------------------------------------------------------------


-- Basic (required)
local helpers = require("helpers")
local keys = require("keys")
local titlebars = require("titlebars")

-- Extra features
local bars = require("bar_themes."..bar_theme_name)
local sidebar = require("noodle.sidebar")
local dock = require("noodle.dock")
local exit_screen = require("noodle.exit_screen_v2")
local layout_popup = require("noodle.layout_popup")
local layout_popup = require("noodle.task_popup")
-- local exit_screen = require("noodle.exit_screen")
-- local start_screen = require("noodle.start_screen")
-- local tag_notifications = require("noodle.tag_notifications")


-- Error handling -------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------


-- Variable definitions 
-------------------------------------------------------------------------------------------------------------
terminal = "urxvtc"
-- -geometry
terminal_geometry = "-g 85x33"
-- Some terminals do not respect spawn callbacks
floating_terminal = "alacritty" -- clients with class "fst" are set to be floating (check awful.rules below)
browser = "chromium"  -- superkey + F1
editor = "subl3" -- superkey + F2
editor_cmd = terminal.." -e nvim" -- shift + superkey + e
filemanager = "thunar" -- superkey + F3
tmux = terminal .. " -e tmux new "

-- Font width and height for drawing terminal
terminal_font_width = 7
terminal_font_height = 19

local setwallpaper = true

dmenu_script = [[
dmenu_run \
    -p 'Launch application: '               \
    -fn ']] .. text_font .. "-11" ..    [[' \
    -nb ']] .. beautiful.xbackground .. [[' \
    -nf ']] .. beautiful.xforeground .. [[' \
    -sb ']] .. beautiful.xcolor2     .. [[' \
    -sf ']] .. beautiful.xbackground .. [[' \
    -h ]] .. beautiful.wibar_height ..  [[  \
    -class 'dmenu'
]]


rofi_script = [[
bash -c "
    rofi -modi run,drun -show drun -line-padding 4 \
         -columns 1 -padding 20 -hide-scrollbar    \
         -show-icons -icon-theme 'Papirus-Dark'    \
         -lines 10 -width 31"
]]

-- Get screen geometry
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- I only ever use these 3
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------


-- Notifications --------------------------------------------------------------------------------------------
-- TODO: some options are not respected when the notification is created
-- through lib-notify. Naughty works as expected.

-- Icon size
naughty.config.defaults['icon_size'] = beautiful.notification_icon_size

-- Timeouts
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 2
naughty.config.presets.critical.timeout = 12

-- Apply theme variables
naughty.config.padding = beautiful.notification_padding
naughty.config.spacing = beautiful.notification_spacing
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.border_width = beautiful.notification_border_width

naughty.config.presets.normal = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.xbackgroundtp,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.low = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.xbackgroundtp,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.ok = naughty.config.presets.low
naughty.config.presets.info = naughty.config.presets.low
naughty.config.presets.warn = naughty.config.presets.normal

naughty.config.presets.critical = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_crit_fg,
    bg           = beautiful.notification_crit_bg,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}
-------------------------------------------------------------------------------------------------------------


-- Menu ----------------------------------------------------------------------------------------------------- 
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end, beautiful.keyboard_icon},
    { "restart", awesome.restart, beautiful.reboot_icon }
}

myeditormenu = {
    { "Sublime text", editor, beautiful.sublime_text_icon },
    { "Android studio", "android-studio", beautiful.android_studio_icon },
    { "Intelia idea", "idea", beautiful.intellij_idea_icon },
    { "Vim", editor_cmd, beautiful.vim_icon }
}

mymainmenu = awful.menu({ items = {
    { "awesome", myawesomemenu, beautiful.home_icon },
    { "browser", browser, beautiful.firefox_icon },
    { "terminal", terminal, beautiful.terminal_icon },
    { "editors", myeditormenu, beautiful.keyboard_icon },
    { "files", filemanager, beautiful.files_icon },
    { "search", function() awful.spawn.with_shell(rofi_script) end, beautiful.search_icon },
    { "telegram",
    function ()
        local matcher = function (c)
            return awful.rules.match(c, {class = 'TelegramDesktop'})
        end
        awful.client.run_or_raise("telegram-desktop", matcher)
    end,
    beautiful.telegram_icon },
    { "ncmpcpp",
    function ()
        local matcher = function (c)
            return awful.rules.match(c, {name = 'ncmpcpp', delayed_placement = awful.placement.next_to_mouse})
        end
        awful.client.run_or_raise(terminal .. " -e ncmpcpp", matcher)
    end,
    beautiful.music_icon },
    { "gimp",
    function ()
        local matcher = function (c)
            return awful.rules.match(c, {class = 'Gimp'})
        end
        awful.client.run_or_raise("gimp", matcher)
    end,
    beautiful.gimp_icon },
    { "appearance", "xfce4-settings-manager", beautiful.appearance_icon },
    { "exit screen", function() exit_screen_show() end, beautiful.poweroff_icon }
}
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-------------------------------------------------------------------------------------------------------------


-- Init screen ----------------------------------------------------------------------------------------------
local function set_wallpaper(s)
    -- Wallpaper
    if ( setwallpaper) then
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end

            -- Method 1: Built in function
            -- gears.wallpaper.maximized(wallpaper, s, true)

            -- Method 2: Set theme's wallpaper with feh
            -- awful.spawn.with_shell("feh --bg-fill " .. wallpaper)
            awful.spawn.with_shell("$HOME/.fehbg")
            -- Method 3: Set last wallpaper with feh
            -- awful.spawn.with_shell(os.getenv("HOME") .. "/.fehbg")
        end
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    -- Tag layouts
    local l = awful.layout.suit -- Alias to save time :)
    -- local layouts = { l.max, l.floating, l.max, l.max , l.tile,
    --     l.max, l.max, l.max, l.floating, l.tile}
    local layouts = { l.floating, l.floating, l.floating, l.tile , l.tile,
    l.max, l.max, l.max, l.tile, l.max}

    -- Tag names
    local tagnames = beautiful.tagnames or { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

    local scr = 1
    
    -- Create tags
    awful.tag.add(tagnames[1], {
        layout = layouts[1],
        screen = scr,
        selected = true,
    })
    awful.tag.add(tagnames[2], {
        layout = layouts[2],
        screen = scr,
    })
    awful.tag.add(tagnames[3], {
        layout = layouts[3],
        screen = scr,
    })
    awful.tag.add(tagnames[4], {
        layout = layouts[4],
        master_width_factor = 0.6,
        screen = scr,
    })
    awful.tag.add(tagnames[5], {
        layout = layouts[5],
        master_width_factor = 0.65,
        screen = scr,
    })
    awful.tag.add(tagnames[6], {
        layout = layouts[6],
        screen = scr,
    })
    awful.tag.add(tagnames[7], {
        layout = layouts[7],
        screen = scr,
    })
    awful.tag.add(tagnames[8], {
        layout = layouts[8],
        screen = scr,
    })
    awful.tag.add(tagnames[9], {
        layout = layouts[9],
        screen = scr,
    })
    awful.tag.add(tagnames[10], {
        layout = layouts[10],
        screen = scr,
    })

    -- Create all tags at once (without seperate configuration for each tag)
    -- awful.tag(tagnames, s, layouts)
end)
-------------------------------------------------------------------------------------------------------------

local function show_titlebars(c, show)
    if show then
        awful.titlebar.show(c, "top")
        awful.titlebar.show(c, "left")
        awful.titlebar.show(c, "right")
        awful.titlebar.show(c, "bottom")
    else
        awful.titlebar.hide(c, "top")
        awful.titlebar.hide(c, "left")
        awful.titlebar.hide(c, "right")
        awful.titlebar.hide(c, "bottom")
    end
end

-- Rules ----------------------------------------------------------------------------------------------------
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = { border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keys.clientkeys,
            buttons = keys.clientbuttons,
            screen = awful.screen.preferred,
            size_hints_honor = false,
            honor_workarea = true,
            honor_padding = true,
            delayed_placement = awful.placement.centered }
        },
         
    { rule_any = { type = { "normal", "dialog"}, role = { "pop-up" },
       }, properties = { titlebars_enabled = true },
    },

    -- Floating clients
    { rule_any = {
        instance = {
            "DTA",  -- Firefox addon DownThemAll.
            "copyq",  -- Includes session name in class.
        },
        class = {
            "mpv",
            "Gpick",
            "Lxappearance",
            "Nm-connection-editor",
            "File-roller",
            "Xfce4-taskmanager",
        },
        name = {
            "Event Tester",  -- xev
            "htop",
        },
        role = {
            "AlarmWindow",  -- Thunderbird's calendar.
            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        },
        type = {
            "dialog",
        }
    }, properties = { floating = true, ontop = false }},

    -- Fullscreen clients
    { rule_any = {
        class = {
            "dota2",
            "Terraria.bin.x86",
            "dontstarve_steam",
        },
    }, properties = { fullscreen = true }},

    -- Centered clients
    { rule_any = {
        type = {
            "dialog",
        },
        class = {
            "Steam",
            "discord",
        },
        role = {
            "GtkFileChooserDialog",
            "conversation",
        }
    }, properties = {},
    callback = function (c)
        awful.placement.centered(c,{honor_workarea=true})
    end
    },

    { rule = 
        { class = "Transmission" },
            properties = {  tag = beautiful.tagnames[10], focus = true } 
    },

    { rule = 
        { name = "Параметры торрента" },
            properties = {  width = screen_width * 0.75, height = screen_height * 0.7,  delayed_placement = awful.placement.centered, switchtotag = true  } 
    },

    -- Titlebars OFF (explicitly)
    -- Titlebars of these clients will be hidden regardless of the theme setting
    { rule_any = {
        class = {
            "qutebrowser",
            "Transmission",
            "discord",
            "TelegramDesktop",
            "Firefox",
            "Steam",
            "Lutris",
            "MComix",
            "Pulseaudio-equalizer-gtk",
            "Oomox",
            "File-roller",
            "Thunar",
            "Chromium",
            "Thunderbird",
            "Subl3",
            "jetbrains-studio",
            "jetbrains-idea-ce",
        },
    }, properties = {},
    callback = function (c)
        if not beautiful.titlebars_imitate_borders then
            --awful.titlebar.hide(c)
            show_titlebars(c, false)
        end
    end
    },


    -- Titlebars ON (explicitly)
    -- Titlebars of these clients will be shown regardless of the theme setting
    { rule_any = {
        class = {
            --"???",
        },
        type = {
            "dialog",
        },
        role = {
            "conversation",
        }
    }, properties = {},
    callback = function (c)
        --awful.titlebar.show(c)
        show_titlebars(c, true)
    end
    },

    -- Skip taskbar
    { rule_any = {
        class = {
            --"feh",
        },
    }, properties = { skip_taskbar = true }
    },

    -- Fixed terminal geometry
    { rule = { class = "URxvt" },   properties = {  size_hints_honor = false  },
    },


    -- Icons
    -------------------------------------------------------------
    -- { rule = { class = "URxvt" },   properties = { },
    -- callback = function (c)
    --     local icon = gears.surface(beautiful.terminal_icon)
    --     c.icon = icon._native
    --     icon:finish()
    -- end },

    -- { rule = { class = "Alacritty" },   properties = { },
    -- callback = function (c)
    --     local icon = gears.surface(beautiful.terminal_icon)
    --     c.icon = icon._native
    --     icon:finish()
    -- end },

    -- { rule = { class = "st-256color" },   properties = { },
    -- callback = function (c)
    --     local icon = gears.surface(beautiful.terminal_icon)
    --     c.icon = icon._native
    --     icon:finish()
    -- end },
    ------------------------------------------------------------- 


    -- Pavucontrol
    { rule_any = {
        class = {
            "Pavucontrol",
        },
    }, properties = { floating = true, width = screen_width * 0.45, height = screen_height * 0.8 }
    },

    -- Galculator
    { rule_any = {
        class = {
            "Galculator",
        },
    },
    except_any = {
        type = { "dialog" }
    },
    properties = { floating = true, width = screen_width * 0.2, height = screen_height * 0.4 }
    },

    -- Rofi configuration
    -- Needed only if option "-normal-window" is used
    { rule_any = {
        class = {
            "Rofi",
        },
    }, properties = { skip_taskbar = true, floating = true, ontop = true, sticky = true },
    callback = function (c)
        awful.placement.centered(c,{honor_workarea=true})
        if not beautiful.titlebars_imitate_borders then
            --awful.titlebar.hide(c)
            show_titlebars(c, false)
        end
    end
    },

    -- Screenruler
    { rule_any = {
        class = {
            "Screenruler",
        },
    }, properties = { border_width = 0, floating = true, ontop = true },
    callback = function (c)
        --awful.titlebar.hide(c)
        show_titlebars(c, false)
        awful.placement.centered(c,{honor_workarea=true})
    end
    },

    -- Scratchpad
    { rule_any = {
        class = {
            "scratchpad",
        },
    }, properties = { tag = awful.screen.focused().tags[10], skip_taskbar = false, floating = true, ontop = false, minimized = true, sticky = false, width = screen_width * 0.7, height = screen_height * 0.75},
    callback = function (c)
        awful.placement.centered(c,{honor_workarea=true})
        gears.timer.delayed_call(function()
            c.urgent = false
        end)
    end
    },

    -- Music clients
    { rule_any = {
        class = {
            "music",
        },
        name = {
            "Music Terminal",
        },
    }, properties = { floating = true, width = screen_width * 0.3, height = screen_height * 0.7},
    -- callback = function (c)
        -- awful.placement.centered(c,{honor_workarea=true})
    -- end
    },

    -- Image viewers
    { rule_any = {
        class = {
            "feh",
            "mpv",
            "File-roller",  
        },
        name = {
            "htop",
            "upd",
        },
    }, properties = { floating = true, width = screen_width * 0.56, height = screen_height * 0.59},
    callback = function (c)
        awful.placement.centered(c,{honor_workarea=true})
    end
    },


    -- ncmpcpp
    { rule = { name = "ncmpcpp" },
        properties = { floating = true, width = dpi(300), height = screen_height * 0.75 },
        callback = function (c)
            c.shape = helpers.rrect(dpi(6))
        end 
    },

    -- Steam guard
    { rule = { name = "Steam Guard - Computer Authorization Required" },
    properties = { floating = true },
    callback = function (c)
        -- gears.timer.delayed_call(function()
        --     awful.placement.centered(c,{honor_workarea=true})
        -- end)
    end
    },

    ---------------------------------------------
    -- Start application on specific workspace --
    ---------------------------------------------
    -- Browsing
    { rule_any = {
        class = {
            "Firefox",
            "Google-chrome",
            "Chromium",
            "qutebrowser",
        },
        except_any = {
            role = { "GtkFileChooserDialog" },
            type = { "dialog" }
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[1], switchtotag = true } },

    -- Coding
    { rule_any = {
        class = {
          "Subl3",
          "jetbrains-studio",
          "jetbrains-idea-ce",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[2], switchtotag = true } },

    -- File manager
    { rule_any = {
        class = {
            "Thunar"
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[3], switchtotag = true } },

    -- Chatting
    { rule_any = {
        class = {
            "discord",
            "TelegramDesktop",
            "Signal",
            "TeamSpeak 3",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[5], floating = false } },

    -- Editing
    -- { rule_any = {
    --     class = {
    --       "Emacs",
    --       "Subl3",
    --       },
    --  }, properties = { screen = 1, tag = awful.screen.focused().tags[4] } },

    -- Photo editing
    { rule_any = {
        class = {
            "Gimp",
            "Inkscape",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[6] } },

    -- Mail
    { rule_any = {
        class = {
            "Thunderbird",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[7] } },

    -- Gaming clients
    { rule_any = {
        class = {
            "Steam",
            "battle.net.exe",
            "Lutris",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[8] } },

    -- Media
    { rule_any = {
        class = {
            "mpvtube",
            -- "mpv",
        },
    }, properties = { screen = 1, tag = awful.screen.focused().tags[9] },
    callback = function (c)
        -- awful.placement.centered(c,{honor_workarea=true})
        gears.timer.delayed_call(function()
            c.urgent = false
        end)
    end
},

-- Miscellaneous
{ rule_any = {
    class = {
        "Deluge",
        "VirtualBox Manager",
    },
}, properties = { screen = 1, tag = awful.screen.focused().tags[10] } },

}

-- placement, that should be applied after setting x/y/width/height/geometry
function awful.rules.delayed_properties.delayed_placement(c, value, props)
    if props.delayed_placement then
        awful.rules.extra_properties.placement(c, props.delayed_placement, props)
    end
end
-------------------------------------------------------------------------------------------------------------


-- Signals --------------------------------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set every new window as a slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

end)


-- Hide titlebars if required by the theme
client.connect_signal("manage", function (c)
    if not beautiful.titlebars_enabled then
        --awful.titlebar.hide(c)
        show_titlebars(c, false)
    end
end)

-- If the layout is not floating, every floating client that appears is centered
-- If the layout is floating, and there is no other client visible, center it
client.connect_signal("manage", function (c)
    if not awesome.startup then
        if awful.layout.get(mouse.screen) ~= awful.layout.suit.floating then
            awful.placement.centered(c,{honor_workarea=true})
        else if #mouse.screen.clients == 1 then
                awful.placement.centered(c,{honor_workarea=true})
            end
        end
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--        and awful.client.focus.filter(c) then
--        client.focus = c
--    end
--end)

-- When a client starts up in fullscreen, resize it to cover the fullscreen a short moment later
-- Fixes wrong geometry when titlebars are enabled
--client.connect_signal("property::fullscreen", function(c)
client.connect_signal("manage", function(c)
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then
                c:geometry(c.screen.geometry)
            end
        end)
    end
end)

-- Center client when floating property changes
--client.connect_signal("property::floating", function(c)
--awful.placement.centered(c,{honor_workarea=true})
--end)

-- Apply shapes
-- beautiful.notification_shape = helpers.infobubble(beautiful.notification_border_radius)
beautiful.notification_shape = helpers.rrect(beautiful.notification_border_radius)
beautiful.snap_shape = helpers.rrect(beautiful.border_radius * 2)
beautiful.taglist_shape = helpers.rrect(beautiful.taglist_item_roundness)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Set mouse resize mode (live or after)
awful.mouse.resize.set_mode("live")

-- Floating: restore geometry
tag.connect_signal('property::layout',
function(t)
    for k, c in ipairs(t:clients()) do
        if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
            -- Geometry x = 0 and y = 0 most probably means that the
            -- clients have been spawned in a non floating layout, and thus
            -- they don't have their floating_geometry set properly.
            -- If that is the case, don't change their geometry
            local cgeo = awful.client.property.get(c, 'floating_geometry')
            if cgeo ~= nil then
                if not (cgeo.x == 0 and cgeo.y == 0) then
                    c:geometry(awful.client.property.get(c, 'floating_geometry'))
                end
            end
            --c:geometry(awful.client.property.get(c, 'floating_geometry'))
        end
    end
end
)

client.connect_signal('manage',
function(c)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
        awful.client.property.set(c, 'floating_geometry', c:geometry())
    end
end
)

client.connect_signal('property::geometry',
function(c)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
        awful.client.property.set(c, 'floating_geometry', c:geometry())
    end
end
)

-- Make rofi able to unminimize minimized clients
client.connect_signal("request::activate",
function(c, context, hints)
    if not awesome.startup then
        if c.minimized then
            c.minimized = false
        end
        awful.ewmh.activate(c, context, hints)
    end
end
)

-- Disconnect the client ability to request different size and position
-- client.disconnect_signal("request::geometry", awful.ewmh.client_geometry_requests)

-- Battery notifications
-- The signals are sent by a udev rule.
local last_battery_notification_id
awesome.connect_signal(
  "charger_plugged", function(c)
    notification = naughty.notify({
        title = "Juice status:",
        text = "Your battery is charging!",
        icon = beautiful.battery_charging_icon,
        timeout = 3,
        replaces_id = last_battery_notification_id
    })
    last_battery_notification_id = notification.id
end)
awesome.connect_signal(
  "charger_unplugged", function(c)
    notification = naughty.notify({
        title = "Juice status:",
        text = "Your battery is discharging!",
        icon = beautiful.battery_icon,
        timeout = 3,
        replaces_id = last_battery_notification_id
    })
    last_battery_notification_id = notification.id
end)
awesome.connect_signal(
  "battery_full", function(c)
    notification = naughty.notify({
        title = "Juice status:",
        text = "Full! Your tank is topped up!",
        icon = beautiful.battery_icon,
        timeout = 3,
        replaces_id = last_battery_notification_id
    })
    last_battery_notification_id = notification.id
end)
-- awesome.connect_signal(
--   "battery_low", function(c)
--     notification = naughty.notify({
--         title = "Juice status:",
--         text = "Low. Running out of juice soon!",
--         icon = beautiful.battery_icon,
--         timeout = 5,
--         replaces_id = last_battery_notification_id
--     })
--     last_battery_notification_id = notification.id
-- end)
awesome.connect_signal(
  "battery_critical", function(c)
    notification = naughty.notify({
        title = "Juice status:",
        text = "Critical! Where is the cable?!",
        icon = beautiful.battery_icon,
        timeout = 0,
        replaces_id = last_battery_notification_id
    })
    last_battery_notification_id = notification.id
end)

collectgarbage("setpause", 160)
collectgarbage("setstepmul", 400)

-- awesome.connect_signal("refresh", function() collectgarbage("collect") end)

-- Startup applications
awful.spawn.with_shell( os.getenv("HOME") .. "/.config/awesome/autostart.sh")
-------------------------------------------------------------------------------------------------------------
