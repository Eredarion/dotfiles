
--[[

     Awesome WM configuration
     by alfunx (Alphonse Mariya)

--]]

local awful = require("awful")
local beautiful = require("beautiful")

local config = { }

function config.init(context)

    -- Rules to apply to new clients (through the "manage" signal)
    awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     delayed_placement = awful.placement.centered 
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.

    { rule_any = {
        class = {
          "Firefox",
          "Google-chrome",
          "Chromium",
          "qutebrowser" }}, properties = { tag = "1" } },

    { rule_any = { class = { "mpv", "feh" }},
     properties = { width = 720, height = 406, delayed_placement = awful.placement.centered } },

    { rule = { class = "Thunar" },
     properties = {  tag = awful.util.tagnames[3], } },

    { rule = { class = "URxvt" },
     properties = {  size_hints_honor = false } },

    { rule = { class = "Transmission" },
     properties = {  tag = "5", focus = true } },

     { rule = { name = "Параметры торрента" },
     properties = {  width = 900, height = 500,  delayed_placement = awful.placement.centered  } },

     

    { rule_any = {
        class = {
          "Subl3",
          "jetbrains-studio",
          "jetbrains-idea-ce" }}, properties = { screen = 1, tag = "2"} },
     
}

 -- placement, that should be applied after setting x/y/width/height/geometry
    function awful.rules.delayed_properties.delayed_placement(c, value, props)
        if props.delayed_placement then
            awful.rules.extra_properties.placement(c, props.delayed_placement, props)
        end
    end

end

return config
