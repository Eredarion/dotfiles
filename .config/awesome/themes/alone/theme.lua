local gears            = require("gears")
local lain             = require("lain")
local awful            = require("awful")
local wibox            = require("wibox")
local naughty          = require("naughty")
local xresources       = require("beautiful.xresources")
local xrdb             = xresources.get_current_theme()
local dpi              = xresources.apply_dpi
local os, math, string = os, math, string
local vicious          = require("vicious")

local colors = { }

colors.bw_0             = xrdb.background
colors.bw_1             = xrdb.color1
colors.bw_2             = "#BEBEBE"
colors.bw_3             = xrdb.color3
colors.bw_4             = xrdb.color4
colors.bw_5             = xrdb.color5
colors.bw_6             = xrdb.color4
colors.bw_7             = xrdb.color7
colors.bw_8             = xrdb.color8
colors.bw_9             = xrdb.foreground
colors.bw_10            = xrdb.color10

local my_table          = awful.util.table or gears.table

local theme             = { } 
theme.name              = "alone"
theme.dir               = string.format("%s/.config/awesome/themes/%s", os.getenv("HOME"), theme.name)  
theme.wallpaper         = theme.dir .. "/wallpapers/wall.png"

-- Font ---------------------------------------------------------------------------------------------------------------
local font_name                                 = "SF Pro Text"
local font_size                                 = "8"
theme.font                                      = font_name .. " " .. "Medium"      .. " " .. font_size
theme.font_bold                                 = font_name .. " " .. "Medium"      .. " " .. font_size
theme.font_notification                         = font_name .. " " .. "Medium"      .. " " .. "8"
theme.font_italic                               = font_name .. " " .. "Italic"      .. " " .. font_size
theme.font_bold_italic                          = font_name .. " " .. "Bold Italic" .. " " .. font_size
theme.iconFont                                  = "Font Awesome 5 Free Regular 9"
theme.iconFont8                                 = "Font Awesome 5 Free 11"
theme.materialIconFont                          = "Material Icons Regular 10"
theme.font_big                                  = "Material Icons Regular "  .. " 20"
theme.taglist_font                              = "Mplus 1p Medium 8"
-----------------------------------------------------------------------------------------------------------------------


-- Border colors ------------------------------------------------------------------------------------------------------
theme.accent                                    = colors.red_2
theme.border_normal                             = colors.bw_2
theme.border_focus                              = colors.bw_9
theme.border_marked                             = colors.bw_9
-----------------------------------------------------------------------------------------------------------------------


-- Foreground and background colors -----------------------------------------------------------------------------------
theme.fg_normal                                 = colors.bw_0
theme.fg_focus                                  = colors.bw_9
theme.fg_urgent                                 = theme.accent
theme.bg_normal                                 = colors.bw_0
theme.bg_focus                                  = theme.border_normal
theme.bg_urgent                                 = theme.border_normal
-----------------------------------------------------------------------------------------------------------------------


-- Taglist colors -----------------------------------------------------------------------------------------------------
theme.taglist_fg_normal                         = colors.bw_0
theme.taglist_fg_occupied                       = colors.bw_0
theme.taglist_fg_empty                          = colors.bw_3
theme.taglist_fg_volatile                       = colors.bw_0
theme.taglist_fg_focus                          = colors.bw_0
theme.taglist_fg_urgent                         = theme.accent
theme.taglist_bg_normal                         = theme.border_focus
theme.taglist_bg_occupied                       = theme.border_focus
theme.taglist_bg_empty                          = theme.border_focus
theme.taglist_bg_volatile                       = theme.border_focus
theme.taglist_bg_focus                          = colors.bw_2
theme.taglist_bg_urgent                         = theme.border_focus
-----------------------------------------------------------------------------------------------------------------------


-- Tasklist colors ----------------------------------------------------------------------------------------------------
theme.tasklist_font_normal                      = theme.font
theme.tasklist_font_focus                       = theme.font
theme.tasklist_font_urgent                      = theme.font
theme.tasklist_fg_normal                        = colors.bw_3
theme.tasklist_fg_focus                         = colors.bw_0
theme.tasklist_fg_minimize                      = colors.bw_2
theme.tasklist_fg_urgent                        = theme.accent
theme.tasklist_bg_normal                        = colors.bw_2
theme.tasklist_bg_focus                         = theme.border_focus
theme.tasklist_bg_urgent                        = theme.border_focus
-----------------------------------------------------------------------------------------------------------------------

theme.titlebar_fg_normal                        = colors.bw_9
theme.titlebar_fg_focus                         = colors.bw_9
theme.titlebar_fg_marked                        = colors.bw_9
theme.titlebar_bg_normal                        = theme.border_normal
theme.titlebar_bg_focus                         = theme.border_focus
theme.titlebar_bg_marked                        = theme.border_marked

theme.hotkeys_border_width                      = theme.border_width
theme.hotkeys_border_color                      = theme.border_focus
theme.hotkeys_group_margin                      = dpi(50)

theme.prompt_bg                                 = colors.bw_0
theme.prompt_fg                                 = theme.fg_normal
theme.bg_systray                                = colors.bw_9

theme.border_width                              = dpi(1)
-- theme.border_radius                             = dpi(8)
theme.border_radius                             = dpi(0)
theme.fullscreen_hide_border                    = true
theme.maximized_hide_border                     = true
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(250)
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.tasklist_spacing                          = dpi(0)
theme.useless_gap                               = dpi(5)
theme.systray_icon_spacing                      = dpi(4)

theme.snap_bg                                   = theme.border_focus
theme.snap_shape                                = function(cr, w, h)
                                                      gears.shape.rounded_rect(cr, w, h, theme.border_radius or 0)
                                                  end

theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .. "/icons/awesome.png"

theme.layout_cascadetile                        = theme.dir .. "/layouts/cascadetile.png"
theme.layout_centerwork                         = theme.dir .. "/layouts/centerwork.png"
theme.layout_cornerne                           = theme.dir .. "/layouts/cornerne.png"
theme.layout_cornernw                           = theme.dir .. "/layouts/cornernw.png"
theme.layout_cornerse                           = theme.dir .. "/layouts/cornerse.png"
theme.layout_cornersw                           = theme.dir .. "/layouts/cornersw.png"
theme.layout_dwindle                            = theme.dir .. "/layouts/dwindle.png"
theme.layout_fairh                              = theme.dir .. "/layouts/fairh.png"
theme.layout_fairv                              = theme.dir .. "/layouts/fairv.png"
theme.layout_floating                           = theme.dir .. "/layouts/floating.png"
theme.layout_fullscreen                         = theme.dir .. "/layouts/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/layouts/magnifier.png"
theme.layout_max                                = theme.dir .. "/layouts/max.png"
theme.layout_spiral                             = theme.dir .. "/layouts/spiral.png"
theme.layout_tile                               = theme.dir .. "/layouts/tile.png"
theme.layout_tilebottom                         = theme.dir .. "/layouts/tilebottom.png"
theme.layout_tileleft                           = theme.dir .. "/layouts/tileleft.png"
theme.layout_tiletop                            = theme.dir .. "/layouts/tiletop.png"


theme.tooltip_fg                                = theme.titlebar_fg_focus
theme.tooltip_bg                                = theme.titlebar_bg_normal
theme.tooltip_border_color                      = theme.border_normal
theme.tooltip_border_width                      = theme.border_width


-- Notification -------------------------------------------------------------------------------------------------------
theme.notification_fg                           = colors.bw_9
theme.notification_bg                           = theme.bg_normal
theme.notification_border_color                 = theme.border_focus
theme.notification_border_width                 = theme.border_width
theme.notification_icon_size                    = dpi(60)
naughty.config.defaults['icon_size'] = dpi(50)
theme.notification_opacity                      = 1
theme.notification_max_width                    = dpi(300)
theme.notification_max_height                   = dpi(80)
-- theme.notification_height = dpi(80)
-- theme.notification_width = dpi(300)
theme.notification_margin                       = dpi(10)
-- theme.notification_shape                        = function(cr, width, height)
--   gears.shape.transform(gears.shape.parallelogram) : rotate(0)(cr, width, height, width)
-- end

naughty.config.padding                          = dpi(6)
naughty.config.spacing                          = dpi(10)
naughty.config.defaults.timeout                 = 5
naughty.config.defaults.margin                  = theme.notification_margin
naughty.config.defaults.border_width            = theme.notification_border_width

naughty.config.presets.normal                   = {
                                                      font         = theme.font_notification,
                                                      fg           = theme.notification_fg,
                                                      bg           = theme.notification_bg,
                                                      border_width = theme.notification_border_width,
                                                      margin       = theme.notification_margin,
                                                  }

naughty.config.presets.low                      = naughty.config.presets.normal
naughty.config.presets.ok                       = naughty.config.presets.normal
naughty.config.presets.info                     = naughty.config.presets.normal
naughty.config.presets.warn                     = naughty.config.presets.normal

naughty.config.presets.critical                 = {
                                                      font         = theme.font_notification,
                                                      fg           = colors.red_2,
                                                      bg           = theme.notification_bg,
                                                      border_width = theme.notification_border_width,
                                                      margin       = theme.notification_margin,
                                                      timeout      = 0,
                                                  }

local markup = lain.util.markup
-----------------------------------------------------------------------------------------------------------------------


-- Spacing ------------------------------------------------------------------------------------------------------------
local space = wibox.widget {
    widget = wibox.widget.separator,
    orientation = "vertical",
    forced_width = dpi(3),
    thickness = dpi(3),
    color = "#00000000",
}

-- Separator
local vert_sep = wibox.widget {
    widget = separator,
    orientation = 'vertical',
    border_width = 2,
    color = '#000000',
}
-----------------------------------------------------------------------------------------------------------------------


-- Textclock ----------------------------------------------------------------------------------------------------------
os.setlocale(os.getenv("LANG")) -- to localize the clock
local clock = awful.widget.watch(
    "date +'%R'", 5,
    function(widget, stdout)
        widget:set_markup(markup.fontfg(theme.font_bold, colors.bw_0, stdout))
    end
)

local clock_widget = wibox.widget {
    {
        clock,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}

-- Calendar
theme.cal = lain.widget.cal {
    cal = "cal --color=always --monday",
    attach_to = { clock_widget },
    icons = "",
    notification_preset = naughty.config.presets.normal,
}
-----------------------------------------------------------------------------------------------------------------------


-- CPU ----------------------------------------------------------------------------------------------------------------
local cpu_icon = wibox.widget.textbox("<span font=\"".. theme.iconFont .."\"></span> ")
local cpu = lain.widget.cpu {
    timeout = 5,
    settings = function()
        local _color = bar_fg
        local _font = theme.font

        if tonumber(cpu_now.usage) >= 90 then
            _color = colors.red_2
        elseif tonumber(cpu_now.usage) >= 80 then
            _color = colors.orange_2
        elseif tonumber(cpu_now.usage) >= 70 then
            _color = colors.yellow_2
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal,  cpu_now.usage .. "%"))


        widget.core  = cpu_now
    end,
}

local cpu_widget = wibox.widget {
    cpu_icon,
    {
        cpu.widget,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}

cpu_widget:buttons(awful.button({ }, 1, function()
    awful.spawn("urxvtc -geometry 70x22 -e htop -s PERCENT_CPU & disown")
end))
-----------------------------------------------------------------------------------------------------------------------


-- BAT ----------------------------------------------------------------------------------------------------------------
local bat_icon = wibox.widget.textbox()
local bat = lain.widget.bat {
    notify = "off",
    batteries = { "BAT0" },
    ac = "AC",
    settings = function()
        local _color = bar_fg
        local _font = theme.font

        if tonumber(bat_now.perc) <= 10 then
            bat_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
            _color = colors.red_2
        elseif tonumber(bat_now.perc) <= 20 then
            bat_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
            _color = colors.orange_2
        elseif tonumber(bat_now.perc) <= 30 then
            bat_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
            _color = colors.yellow_2
        elseif tonumber(bat_now.perc) <= 50 then
            bat_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
        else
            bat_icon.markup = "<span font=\"".. theme.iconFont8 .."\"></span> "
        end

        if tonumber(bat_now.perc) <= 3 and not bat_now.ac_status == 1 then
            if not bat_now.notification then
                bat_now.notification = naughty.notify {
                    title = "Battery",
                    text = "Your battery is running low.\n"
                        .. "You should plug in your PC.",
                    preset = naughty.config.presets.critical,
                    timeout = 0,
                }
            end
        end

        if bat_now.ac_status == 1 then
            bat_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
            if tonumber(bat_now.perc) >= 95 then
                _color = colors.green_2
            end
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, bat_now.perc .. "%"))
    end,
}

local bat_widget = wibox.widget {
    bat_icon,
    {
        bat.widget,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}
-----------------------------------------------------------------------------------------------------------------------


-- ALSA volume --------------------------------------------------------------------------------------------------------
local vol_icon = wibox.widget.textbox()
theme.volume = lain.widget.alsa {
    settings = function()
        if volume_now.status == "off" then
            vol_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
        elseif tonumber(volume_now.level) == 0 then
            vol_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
        elseif tonumber(volume_now.level) < 50 then
            vol_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
        else 
            vol_icon.markup = "<span font=\"".. theme.iconFont .."\"></span> "
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal, volume_now.level .. "%"))

        if theme.volume.manual then
            if theme.volume.notification then
                naughty.destroy(theme.volume.notification)
            end

            if volume_now.status == "off" then
                vol_text = "Muted"
            else
                vol_text = " " .. volume_now.level .. "%"
            end

            if client.focus and client.focus.fullscreen or volume_now.status ~= volume_before then
                theme.volume.notification = naughty.notify {
                    title = "Audio",
                    text = vol_text,
                }
            end

            theme.volume.manual = false
        end
        volume_before = volume_now.status
    end,
}
-- Initial notification 
theme.volume.manual = true
theme.volume.update()

local vol_widget = wibox.widget {
    vol_icon,
    {
        theme.volume.widget,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}

vol_widget:buttons(gears.table.join(
    awful.button({ }, 1, function()
        awful.spawn.easy_async(string.format("amixer -q set %s toggle", theme.volume.channel),
        function(stdout, stderr, reason, exit_code) --luacheck: no unused args
            theme.volume.manual = true
            theme.volume.update()
        end)
    end),
    awful.button({ }, 5, function()
        awful.spawn.easy_async(string.format("amixer -q set %s 3%%-", theme.volume.channel),
        function(stdout, stderr, reason, exit_code) --luacheck: no unused args
            theme.volume.update()
        end)
    end),
    awful.button({ }, 4, function()
        awful.spawn.easy_async(string.format("amixer -q set %s 3%%+", theme.volume.channel),
        function(stdout, stderr, reason, exit_code) --luacheck: no unused args
            theme.volume.update()
        end)
    end)
))
-----------------------------------------------------------------------------------------------------------------------


-- MEM ----------------------------------------------------------------------------------------------------------------
local mem_icon = wibox.widget.textbox("<span font=\"".. theme.iconFont .."\"></span> ")
local mem = lain.widget.mem {
    timeout = 5,
    settings = function()
        local _color = bar_fg
        local _font = theme.font

        if tonumber(mem_now.perc) >= 90 then
            _color = colors.red_2
        elseif tonumber(mem_now.perc) >= 80 then
            _color = colors.orange_2
        elseif tonumber(mem_now.perc) >= 70 then
            _color = colors.yellow_2
        end

        widget:set_markup(markup.fontfg(theme.font, theme.fg_normal , mem_now.perc .. "%"))

        widget.used  = mem_now.used
        widget.total = mem_now.total
        widget.free  = mem_now.free
        widget.buf   = mem_now.buf
        widget.cache = mem_now.cache
        widget.swap  = mem_now.swap
        widget.swapf = mem_now.swapf
        widget.srec  = mem_now.srec
    end,
}

local mem_widget = wibox.widget {
    mem_icon,
    {
        mem.widget,
        widget = wibox.container.margin,
    },
    layout = wibox.layout.align.horizontal,
}

mem_widget:buttons(awful.button({ }, 1, function()
    if mem_widget.notification then
        naughty.destroy(mem_widget.notification)
    end
    mem.update()
    mem_widget.notification = naughty.notify {
        title = "Memory",
        text = string.format("Total:      \t\t%.2fGB\n", tonumber(mem.widget.total) / 1024)
            .. string.format("Used:       \t\t%.2fGB\n", tonumber(mem.widget.used ) / 1024)
            .. string.format("Free:       \t\t%.2fGB\n", tonumber(mem.widget.free ) / 1024)
            .. string.format("Buffer:     \t\t%.2fGB\n", tonumber(mem.widget.buf  ) / 1024)
            .. string.format("Cache:    \t\t%.2fGB\n", tonumber(mem.widget.cache) / 1024)
            .. string.format("Swap:       \t\t%.2fGB\n", tonumber(mem.widget.swap ) / 1024)
            .. string.format("Swapf:    \t\t%.2fGB\n", tonumber(mem.widget.swapf) / 1024)
            .. string.format("Srec:       \t\t%.2fGB"  , tonumber(mem.widget.srec ) / 1024),
        timeout = 7,
    }
end))
-----------------------------------------------------------------------------------------------------------------------


-- MPD Toggle ---------------------------------------------------------------------------------------------------------
theme.mpd_toggle = wibox.widget.textbox()
vicious.register(
    theme.mpd_toggle,
    vicious.widgets.mpd,
    function(widget, args)
        local label = {["Play"] = "", ["Pause"] = "", ["Stop"] = "" }
            return ("<span font=\"".. theme.iconFont .."\">%s</span> "):format(label[args["{state}"]])
 end)

theme.mpd_toggle:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        os.execute("mpc toggle")
        vicious.force({theme.mpdwidget, theme.mpd_prev, theme.mpd_toggle, theme.mpd_next})
    end),
    awful.button({}, 3, function()
        os.execute("mpc stop")
        vicious.force({theme.mpdwidget, theme.mpd_prev, theme.mpd_toggle, theme.mpd_next})
    end)
))
-----------------------------------------------------------------------------------------------------------------------


-- MPD Previous -------------------------------------------------------------------------------------------------------
theme.mpd_prev = wibox.widget.textbox()
vicious.register(
    theme.mpd_prev,
    vicious.widgets.mpd,
    function(widget, args)
        if args["{state}"] == "Stop" then
            return " "
        else
            return (" <span font=\"".. theme.iconFont .."\"></span> ")
        end
    end)

theme.mpd_prev:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        os.execute("mpc prev")
        vicious.force({theme.mpdwidget, theme.mpd_prev, theme.mpd_toggle, theme.mpd_next})
    end)
))
-----------------------------------------------------------------------------------------------------------------------


-- MPD Next -----------------------------------------------------------------------------------------------------------
theme.mpd_next = wibox.widget.textbox()
vicious.register(
    theme.mpd_next,
    vicious.widgets.mpd,
    function(widget, args)
        if args["{state}"] == "Stop" then
            return ""
        else
            return ("<span font=\"".. theme.iconFont .."\"></span> ")
        end
    end)

theme.mpd_next:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        os.execute("mpc next")
        vicious.force({theme.mpdwidget, theme.mpd_prev, theme.mpd_toggle, theme.mpd_next})
    end)
))
-----------------------------------------------------------------------------------------------------------------------


-- Ncmpcpp ------------------------------------------------------------------------------------------------------------
local terminalRun = wibox.widget.textbox("<span font=\"".. theme.iconFont .."\"></span>")
terminalRun:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        os.execute("urxvtc -geometry 70x25 -e ncmpcpp")
    end),
    awful.button({}, 3, function()
        awful.spawn("/home/ranguel/.config/ncmpcpp/mpdnotify")
    end)
))
-----------------------------------------------------------------------------------------------------------------------


-- Shape --------------------------------------------------------------------------------------------------------------
local shape_left = function(cr, width, height)
  gears.shape.parallelogram(cr, width, height, width-10)
end

local shape_right = function(cr, width, height)
  gears.shape.transform(gears.shape.parallelogram) : translate(0, 0)(cr, width, height, width-10)
end

local shape_end_right = function(cr, width, height)
  gears.shape.transform(shape.isosceles_triangle) : rotate_at(35, 35, math.pi/2)(cr,width,height)
end
-----------------------------------------------------------------------------------------------------------------------


-- Show widget on mouse::enter on parent, hide after mouse::leave + timeout -------------------------------------------
show_on_mouse = function(parent, widget, timeout)
    local timer = gears.timer {
        timeout = timeout or 5,
        callback = function()
            widget:set_visible(false)
        end,
    }
    timer:start()

    parent:connect_signal("mouse::enter", function()
        widget:set_visible(true)
        timer:stop()
    end)

     parent:connect_signal("mouse::leave", function()
        timer:start()
    end)
end
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- Tags
    awful.util.tagnames = { "一", "二", "三", "四", "五" }
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    local gen_tasklist = function()
        -- Create a tasklist widget
        s._tasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = awful.util.tasklist_buttons,
            bg_focus = "#FFFFFF",
            style = {
                shape = function(cr, width, height)
                            gears.shape.parallelogram(cr, width, height, width-10) 
                end,
                shape_border_width = dpi(20),
                shape_border_color = "#a12a12",
            },
            widget_template = {
                {
                    {
                        {
                            layout = wibox.layout.fixed.horizontal,
                            {
                                id     = 'text_role',
                                widget = wibox.widget.textbox,
                            },
                        },
                        halign = 'center',
                        valign = 'center',
                        widget = wibox.container.place,
                    },
                    left = dpi(5),
                    right = dpi(5),
                    top = dpi(5),
                    widget = wibox.container.margin,
                },
                create_callback = function(self, c, index, objects) --luacheck: no unused args
                    local tooltip = awful.tooltip { --luacheck: no unused
                        objects = { self },
                        delay_show = 1,
                        timer_function = function()
                            return c.name
                        end,
                        align = "bottom",
                        mode = "outside",
                        preferred_positions = { "bottom" },
                    }
                end,
                id = 'background_role',
                widget = wibox.container.background,
            },
            layout = {
                layout = wibox.layout.flex.horizontal,
                spacing = dpi(8),
                spacing_widget = {
                    bar_spr,
                    valign = 'center',
                    halign = 'center',
                    widget = wibox.container.place,
                },
            },
        }
    end

      -- For old version (Awesome v4.2)
    if not pcall(gen_tasklist) then
        -- Create a tasklist widget
        s._tasklist = awful.widget.tasklist(s,
        awful.widget.tasklist.filter.currenttags,
        awful.util.tasklist_buttons, {
            bg_focus = theme.tasklist_bg_focus,
             shape = function(cr, width, height)
                            gears.shape.parallelogram(cr, width, height, width-10) 
                end,
                shape_border_width = dpi(0),
                shape_border_color = "#a12a12",
            align = "center" }, nil, wibox.layout.flex.horizontal())
    end

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
        height = 22,
        fg = bar_fg,
        bg = bar_bg,
    }

     -- Create the systray
    local systray_widget = wibox.widget {
       layout = wibox.layout.align.horizontal,
       {
          {
            {
              layout = wibox.layout.align.horizontal,
              wibox.widget.systray(),
            },
          left = dpi(13),
          right = dpi(13),
          top = dpi(0),
          bottom = dpi(0),
          widget = wibox.container.margin,
          },
        shape = shape_left,
        bg = theme.border_focus,
        widget = wibox.container.background
        },
        visible = false,
    }
    show_on_mouse(s.mywibox, systray_widget, 1)

     -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.flex.vertical,
            {
                layout = wibox.layout.align.horizontal,
                { -- Left widgets
                    layout = wibox.layout.fixed.horizontal,

                    space,


                    {  -- Layout box
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          s.mylayoutbox
                        },
                      top = dpi(2),
                      bottom = dpi(2),
                      left = dpi(15),
                      right = dpi(15),
                      widget = wibox.container.margin
                      },
                    shape              = shape_left,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Taglist
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          s.mytaglist
                        },
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_left,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Mpd
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          theme.mpd_prev, space,
                          theme.mpd_toggle, space,
                          theme.mpd_next, space,
                        },
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_left,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },
                  

                  {  -- Run ncmpcpp
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          terminalRun
                        },
                      top = dpi(2),
                      bottom = dpi(2),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_left,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    -- { -- Prompt box
                    --     {
                    --         {
                    --             layout = wibox.layout.align.horizontal,
                    --             s.mypromptbox,
                    --         },
                    --         left = dpi(6),
                    --         right = dpi(6),
                    --         widget = wibox.container.margin,
                    --     },
                    --     bg = theme.prompt_bg,
                    --     widget = wibox.container.background,
                    -- },
              },


                -- Middle widget
                { -- Tasklist
                    {
                        layout = wibox.layout.flex.horizontal,
                        s._tasklist,
                    },
                    widget = wibox.container.background,
                },

                { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,

                    -- Systray
                    systray_widget,


                    {  -- Cpu
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          cpu_widget
                        },
                      top = dpi(0),
                      bottom = dpi(0),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_right,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Memory
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          mem_widget
                        },
                      top = dpi(0),
                      bottom = dpi(0),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_right,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Volume
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          vol_widget
                        },
                      top = dpi(0),
                      bottom = dpi(0),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_right,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Battery
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          bat_widget
                        },
                      top = dpi(0),
                      bottom = dpi(0),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_right,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    {  -- Time
                      {
                        {
                          layout = wibox.layout.fixed.horizontal,
                          clock_widget
                        },
                      top = dpi(0),
                      bottom = dpi(0),
                      left = dpi(13),
                      right = dpi(13),
                      widget = wibox.container.margin
                      },
                    shape              = shape_right,
                    bg                 = theme.border_focus,
                    widget             = wibox.container.background
                    },


                    space,
                },
            },
        },
        -- bottom = theme.border_width,
        -- color = theme.border_focus,
        top = dpi(3),
        bottom = dpi(3),
        widget = wibox.container.margin,
    }
end

return theme
