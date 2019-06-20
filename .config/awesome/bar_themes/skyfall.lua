local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad

local icon_font = "Tinos Nerd Font 13"


-- Widgets --------------------------------------------------------------------------------------------------
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    -- awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ }, 3, function(t)
                        if client.focus then
                          client.focus:move_to_tag(t)
                        end
                    end),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, 
                        function (c)
                            if c == client.focus then
                                c.minimized = true
                            else
                                -- Without this, the following
                                -- :isvisible() makes no sense
                                c.minimized = false
                                if not c:isvisible() and c.first_tag then
                                    c.first_tag:view_only()
                                end
                                -- This will also un-minimize
                                -- the client, if needed
                                client.focus = c
                                c:raise()
                            end
                        end),
                     -- Middle mouse button closes the window
                     awful.button({ }, 2, function (c) c:kill() end),
                     awful.button({ }, 3, function (c) c.minimized = true end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                    end)
)

-- Time
local time_icon = wibox.widget.textbox("<span font=\"".. icon_font .."\"></span>")
time_icon.resize = true
time_icon.align = "center"
time_icon.valign = "center"

local time = awful.widget.watch(
    "date +'%R'", 5,
    function(widget, stdout)
        widget:set_markup(stdout)
    end
)
local time_alt = wibox.widget.textclock("%H:%M")
time_alt.opacity = 1
time_alt.align = "center"
time_alt.valign = "center"
--time_alt.font = text_font .. " 11"

local date_icon = wibox.widget.textbox("<span font=\"".. icon_font .."\"></span>")
local date = wibox.widget.textclock("%d")
local date_day = wibox.widget.textclock("%a")

local time_widget = wibox.widget{
  date_icon,
  date,
  date_day,
  time_icon,
  time_alt,
  pad(0),
  spacing = dpi(6),
  layout = wibox.layout.fixed.horizontal
}

-- Calendar
local month_calendar = awful.widget.calendar_popup.month({ 
    font = text_font .. " bold 10",
    long_weekdays = false,
    spacing  = dpi(3),
    margin = dpi(3),
    style_month = {
        padding = dpi(5), 
    },
    style_header = {
        fg_color = beautiful.xforeground,
        bg_color = beautiful.xcolor0 .. "00",
    },
    style_weekday = {
        fg_color = beautiful.xforeground,
        bg_color = beautiful.xcolor0 .. "00",
    },
    style_normal = {
        fg_color = beautiful.xforeground,
        bg_color = beautiful.xcolor0 .. "00",
    },
    style_focus={
      shape = function(_c, _w, _h) return gears.shape.rounded_rect(_c, _w, _h, 3) end,
      bg_color  = beautiful.xcolor1,
      fg_color  = beautiful.xcolor0,
    },
})
month_calendar:call_calendar (dpi(0), "tr", s)

-- Show calendar
time_widget:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                    month_calendar:toggle()
                 end),
                 awful.button({ }, 2, function ()
                    month_calendar:toggle()
                 end),
                 awful.button({ }, 3, function ()
                    awful.screen.focused().traybox.visible = not awful.screen.focused().traybox.visible

                 end)
))


-- Create text weather widget
local text_weather = require("noodle.text_weather")
local weather_widget_icon = text_weather:get_all_children()[1]
weather_widget_icon.font = icon_font
local weather_widget_text = text_weather:get_all_children()[2]
--weather_widget_text.font = main_font

text_weather:buttons(gears.table.join(
               awful.button({ }, 1, function ()
                  awful.spawn(terminal,
                      { floating = true, width = dpi(900), height = dpi(650), delayed_placement = awful.placement.centered })
               end),
               awful.button({ }, 2, function ()
                
               end),
               awful.button({ }, 3, function ()

               end)
))
-------------------------------------------------------------------------------------------------------------


-- Init screen ---------------------------------------------------------------------------------------------- 
awful.screen.connect_for_each_screen(function(s)
    -- Create a system tray widget
    s.systray = wibox.widget.systray()

    -- Create a wibox that will only show the tray
    -- Hidden by default. Can be toggled with a keybind.
    s.traybox = wibox({visible = false, ontop = true, shape = helpers.rrect(beautiful.border_radius), type = "dock"})
    s.traybox.width = dpi(100)
    s.traybox.height = dpi(25)
    s.traybox.x = s.geometry.width - s.traybox.width - dpi(3)
    s.traybox.y = s.traybox.height + dpi(3)
    -- s.traybox.y = s.geometry.height - s.traybox.height - s.traybox.height / 2
    s.traybox.bg = beautiful.bg_systray
    s.traybox:setup {
      pad(1),
      s.systray,
      pad(1),
      layout = wibox.layout.align.horizontal
    }
    s.traybox:buttons(gears.table.join(
                        -- Middle click - Hide traybox
                        awful.button({ }, 2, function ()
                            s.traybox.visible = false
                        end)
    ))
    -- Hide traybox when mouse leaves
    -- s.traybox:connect_signal("mouse::leave", function ()
    --         s.traybox.visible = false
    -- end)

    -- Create a taglist widget
    -- s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create an icon taglist
    -- local icon_taglist = require("noodle.icon_taglist")

    -- Create a custom text taglist
    local text_taglist = require("noodle.text_taglist")

    -- Create the wibox
    s.mywibox = awful.wibar({ position = beautiful.wibar_position,
                              screen = s,
                              width = beautiful.wibar_width, 
                              height = beautiful.wibar_height})
    -- Wibar items
    -- Add or remove widgets here
    s.mywibox:setup {
        {
            pad(0),
            text_weather,
            spacing = dpi(6),
            layout = wibox.layout.fixed.horizontal
        },
        text_taglist,
        { 
            time_widget,    
            layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    }
    -- local width_geo = awful.screen.focused().geometry.width - dpi(25)
    -- local height_geo = awful.screen.focused().geometry.height - dpi(25)
    -- client.connect_signal("request::geometry", function(c)                                                                                                                                  
    --   if c.width > width_geo and c.height > height_geo then                                                                                                                                                                
    --       s.mywibox.bg = "#12151A"
    --   else
    --       s.mywibox.bg = beautiful.xcolor0                                                                                                                                             
    --   end                                                                                                                                                                                 
    -- end)
    -- s.mywibox:connect_signal("mouse::leave", function () 
    --     s.mywibox.bg = beautiful.xcolor0
    -- end)
end)

-- local s = mouse.screen
-- Show traybox when the mouse touches the rightmost edge of the wibar
-- TODO fix for wibar_position = "top"
-- traybox_activator = wibox({ x = s.geometry.width - 1,
--                             y = s.geometry.height - beautiful.wibar_height,
--                             height = beautiful.wibar_height,
--                             width = 1, opacity = 0, visible = true, 
--                             bg = beautiful.wibar_bg })
-- traybox_activator:connect_signal("mouse::enter", function ()
--     -- awful.screen.focused().traybox.visible = true
--     s.traybox.visible = true
-- end)
-------------------------------------------------------------------------------------------------------------