local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad

local icon_font = "Tinos Nerd Font 13"

local s = mouse.screen
local calendar_visible = false

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
local time_alt = wibox.widget.textclock("<span underline=\"none\">" .. "%H:%M" .. "</span>")
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
-- Create the calendar
local styles = {}
styles.month   = { padding      = dpi(5),
                   fg_color     = beautiful.xcolor7,
                   bg_color     = beautiful.xbackground.."00",
                   border_width = 0,
}
styles.normal  = {}
styles.focus   = { fg_color = beautiful.xbackground,
                   bg_color = beautiful.xcolor1,
                   shape    = function(_c, _w, _h) return gears.shape.rounded_rect(_c, _w, _h, 3) end
                  -- markup   = function(t) return '<b>' .. t .. '</b>' end,
}
styles.header  = { fg_color = beautiful.xcolor7,
                   bg_color = beautiful.xcolor1.."00",
                   --markup   = function(t) return '<span font_desc="sans bold 24">' .. t .. '</span>' end,
}
styles.weekday = { fg_color = beautiful.xcolor7,
                   bg_color = beautiful.xcolor1.."00",
                   --markup   = function(t) return '<b>' .. t .. '</b>' end,
}
local function decorate_cell(widget, flag, date)
    if flag=='monthheader' and not styles.monthheader then
        flag = 'header'
    end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end

    -- Change bg color for weekends
    -- local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
    -- local weekday = tonumber(os.date('%w', os.time(d)))
    -- local default_bg = (weekday==0 or weekday==6) and beautiful.xcolor6 or beautiful.xcolor14

    local default_fg = beautiful.xcolor7
    local default_bg = beautiful.xcolor0.."00"

    local ret = wibox.widget {
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget  = wibox.container.margin
        },
        shape              = props.shape,
        shape_border_color = props.border_color or beautiful.xbackground,
        shape_border_width = props.border_width or 0,
        fg                 = props.fg_color or default_fg,
        bg                 = props.bg_color or default_bg,
        widget             = wibox.container.background
    }
    return ret
end

local calendar_widget = wibox.widget {
    date     = os.date('*t'),
    font     = text_font .. " bold 10",
    long_weekdays = false,
    spacing  = dpi(3),
    fn_embed = decorate_cell,
    widget   = wibox.widget.calendar.month
}

local current_month = os.date('*t').month
calendar_widget:buttons(gears.table.join(
    -- Left Click - Reset date to current date
    awful.button({ }, 1, function ()
        calendar_widget.date = os.date('*t')
    end),
    -- Scroll - Move to previous or next month
    awful.button({ }, 4, function ()
        new_calendar_month = calendar_widget.date.month - 1
        if new_calendar_month == current_month then
            calendar_widget.date = os.date('*t')
        else
            calendar_widget.date = {month = new_calendar_month, year = calendar_widget.date.year} 
        end
    end),
    awful.button({ }, 5, function ()
        new_calendar_month = calendar_widget.date.month + 1
        if new_calendar_month == current_month then
            calendar_widget.date = os.date('*t')
        else
            calendar_widget.date = {month = new_calendar_month, year = calendar_widget.date.year} 
        end
    end)
))

local calendar_wibox = wibox({ x = s.geometry.width - dpi(160) - beautiful.screen_margin,
                            y = dpi(24) + beautiful.screen_margin,
                            height = dpi(200),
                            width = dpi(160),
                            ontop = true,
                            visible = false, 
                            bg = beautiful.xbackgroundtp })

calendar_wibox:setup {
  calendar_widget,
  layout = wibox.layout.fixed.vertical
  -- expand = "none"
}
-- Show calendar
time_widget:buttons(gears.table.join(
                 awful.button({ }, 1, function ()
                    if (awful.screen.focused().traybox.visible) then
                      calendar_wibox.visible = not calendar_wibox.visible
                    else
                      traybox_activator.visible = not traybox_activator.visible
                      calendar_wibox.visible = not calendar_wibox.visible
                    end                
                 end),
                 awful.button({ }, 2, function ()
                    if (awful.screen.focused().traybox.visible) then
                      calendar_wibox.visible = not calendar_wibox.visible
                    else
                      traybox_activator.visible = not traybox_activator.visible
                      calendar_wibox.visible = not calendar_wibox.visible
                    end 
                 end),
                 awful.button({ }, 3, function ()
                    if (calendar_wibox.visible) then
                      awful.screen.focused().traybox.visible = not awful.screen.focused().traybox.visible
                    else
                      traybox_activator.visible = not traybox_activator.visible
                      awful.screen.focused().traybox.visible = not awful.screen.focused().traybox.visible
                    end
                 end)
))


-- Create text weather widget
local text_weather = require("noodle.text_weather")
local weather_widget_icon = text_weather:get_all_children()[1]
weather_widget_icon.font = icon_font
local weather_widget_text = text_weather:get_all_children()[2]
--weather_widget_text.font = main_font

text_weather:connect_signal("mouse::enter", function ()
      sidebar.visible = true
end)

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
    s.traybox.bg = beautiful.xbackgroundtp
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

-- Show traybox when the mouse touches the rightmost edge of the wibar
-- TODO fix for wibar_position = "top"
traybox_activator = wibox({ x = s.geometry.width - dpi(200),
                            y = beautiful.wibar_height,
                            height = dpi(250) - beautiful.wibar_height,
                            width = dpi(200),
                            ontop = true,
                            opacity = 0, 
                            visible = false, 
                            bg = "#000000" })
traybox_activator:connect_signal("mouse::leave", function ()
    -- awful.screen.focused().traybox.visible = true
    if (mouse.coords().x < s.geometry.width - dpi(200) or mouse.coords().y > dpi(240)) then
      s.traybox.visible = false
      calendar_wibox.visible = false
      traybox_activator.visible = false
  end

end)
-------------------------------------------------------------------------------------------------------------