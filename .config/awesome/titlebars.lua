local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")

local helpers = require("helpers")
local titlebars = {}
local pad = helpers.pad

local icon_font = "Font Awesome 5 Free Bold 24"
local icon_font_small = "Font Awesome 5 Free Regular 22"

-- Mouse buttons
titlebars.buttons = gears.table.join(
    -- Left button - move
    -- (Double tap - Toggle maximize) -- A little BUGGY
    awful.button({ }, 1, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)

        -- local function single_tap()
        --   awful.mouse.client.move(c)
        -- end
        -- local function double_tap()
        --   gears.timer.delayed_call(function()
        --       c.maximized = not c.maximized
        --   end)
        -- end
        -- helpers.single_double_tap(single_tap, double_tap)
        -- helpers.single_double_tap(nil, double_tap)
    end),
    -- Middle button - close
    awful.button({ }, 2, function ()
        window_to_kill = mouse.object_under_pointer()
        window_to_kill:kill()
    end),
    -- Right button - resize
    awful.button({ }, 3, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c:raise()
        awful.mouse.client.resize(c)
        -- awful.mouse.resize(c, nil, {jump_to_corner=true})
    end),
    awful.button({ }, 9, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c:raise()
        --awful.placement.centered(c,{honor_workarea=true})
        c.floating = not c.floating
    end),
    -- Side button down - toggle ontop
    awful.button({ }, 8, function()
        local c = mouse.object_under_pointer()
        client.focus = c
        c:raise()
        c.ontop = not c.ontop
    end)
)

-- Disable popup tooltip on titlebar button hover
awful.titlebar.enable_tooltip = false

local prev_image = wibox.widget.imagebox(beautiful.music_icon)
prev_image.forced_width = dpi(300)
--prev_image.forced_height = dpi(300)
prev_image.resize = true
prev_image.align = "center"
prev_image.valign = "center"

local script = [[bash -c '
  IMG_REG="(front|cover|art)\.(jpg|jpeg|png|gif)$"
  DEFAULT_ART="$HOME/.config/awesome/themes/skyfall/icons/music.png"

  file=`mpc current -f %file%`
 
  art="$HOME/]] .. music_directory .. [[/${file%/*}"

  if ]] .. "[[ -d $art ]];" .. [[ then
    cover="$(find "$art/" -maxdepth 1 -type f | egrep -i -m1 "$IMG_REG")"
  fi
  cover="${cover:=$DEFAULT_ART}"

  echo "##"$cover"##"
']]

local resetCover = function ()
    awful.spawn.easy_async(script, 
                function(stdout)
                    prev_image.image = stdout:match('##(.*)##')
                end
            )
end


local playerctl_toggle_icon = wibox.widget.imagebox(beautiful.playerctl_toggle_icon)
playerctl_toggle_icon:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc toggle")
                         end),
                         awful.button({ }, 3, function ()
                             awful.spawn.with_shell("mpvc toggle")
                         end),
                         awful.button({ }, 8, function ()
                             sidebar.visible = false
                             awful.spawn.with_shell("~/scr/Rofi/rofi_mpvtube")
                         end),
                         awful.button({ }, 9, function ()
                             awful.spawn.with_shell("~/scr/info/mpv-query.sh")
                         end)
))

local playerctl_prev_icon = wibox.widget.imagebox(beautiful.playerctl_prev_icon)
playerctl_prev_icon:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc prev")
                             resetCover()
                         end),
                         awful.button({ }, 3, function ()
                             awful.spawn.with_shell("mpvc prev")
                         end)
))


local playerctl_next_icon = wibox.widget.imagebox(beautiful.playerctl_next_icon)
playerctl_next_icon:buttons(gears.table.join(
                         awful.button({ }, 1, function ()
                             awful.spawn.with_shell("mpc next")
                             resetCover()
                         end),
                         awful.button({ }, 3, function ()
                             awful.spawn.with_shell("mpvc next")
                         end)
))


local container = function ( widget )
    return { 
                widget,
                top = dpi(5),
                bottom = dpi(5),
                left = dpi(3),
                right = dpi(3),
                widget = wibox.container.margin
            }
end

local container_for_buttons = function ( widget )
    return { 
                widget,
                top = dpi(4),
                bottom = dpi(4),
                left = dpi(6),
                right = dpi(6),
                widget = wibox.container.margin
            }
end

-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
    local buttons = titlebars.buttons

    local title_widget
    if beautiful.titlebar_title_enabled then
        title_widget = awful.titlebar.widget.titlewidget(c)
        title_widget.font = beautiful.titlebar_font
        title_widget:set_align(beautiful.titlebar_title_align)
    else
        title_widget = wibox.widget.textbox("")
    end

    local titlebar_item_layout
    local titlebar_layout
    if beautiful.titlebar_position == "left" or beautiful.titlebar_position == "right" then
        titlebar_item_layout = wibox.layout.fixed.vertical
        titlebar_layout = wibox.layout.align.vertical
    else
        titlebar_item_layout = wibox.layout.fixed.horizontal
        titlebar_layout = wibox.layout.align.horizontal
    end

    -- Create 4 dummy titlebars around the window to imitate borders
    if beautiful.titlebars_imitate_borders then
        helpers.create_titlebar(c, buttons, "top", beautiful.titlebar_size)
        helpers.create_titlebar(c, buttons, "bottom", beautiful.titlebar_size)
        helpers.create_titlebar(c, buttons, "left", beautiful.titlebar_size)
        helpers.create_titlebar(c, buttons, "right", beautiful.titlebar_size)
    else -- Single titlebar
        -- Custom titlebar for music terminal (usually ncmpcpp)
        -- if c.class == "music" then
        if c.class == "ncmpcpp" or c.name == "ncmpcpp" then
            resetCover()

            -- Music titlebar items
            awful.titlebar(c, {font = beautiful.titlebar_font, position = "top", size = dpi(300)}) : setup {
                nil,
                {
                    nil,
                    { -- Music player buttons
                        -- playerctl_prev_icon,
                        -- pad(1),
                        prev_image,
                        -- pad(1),
                        -- playerctl_next_icon,
                        layout = wibox.layout.fixed.horizontal
                    },
                    nil,
                    expand = "none",
                    layout = wibox.layout.align.vertical,
                },
                nil,
                buttons = buttons,
                expand = "none",
                layout = wibox.layout.align.horizontal,
            }

            awful.titlebar(c, {font = beautiful.titlebar_font, position = "bottom", size = dpi(40)}) : setup {
                nil,
                {
                 {
                    nil,
                    { -- Music player buttons
                        container_for_buttons(playerctl_prev_icon),
                        pad(1),
                        { 
                            playerctl_toggle_icon,
                            top = dpi(2),
                            bottom = dpi(2),
                            left = dpi(6),
                            right = dpi(6),
                            widget = wibox.container.margin
                        },
                        pad(1),
                        container_for_buttons(playerctl_next_icon),
                        layout = wibox.layout.fixed.horizontal
                    },
                    nil,
                    expand = "none",
                    layout = wibox.layout.align.vertical,
                 },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
                },
                nil,
                buttons = buttons,
                expand = "none",
                layout = wibox.layout.align.horizontal,
            }
        else -- Default window titlebar
            awful.titlebar(c, {font = beautiful.titlebar_font, position = beautiful.titlebar_position, size = beautiful.titlebar_size}) : setup {
                -- Titlebar items
                { -- Left
                    -- In the presence of buttons, use padding to center the title if needed.
                    --pad(10),
                    -- Clickable buttons
                    -- awful.titlebar.widget.closebutton    (c),
                    -- awful.titlebar.widget.minimizebutton   (c),
                    -- awful.titlebar.widget.maximizedbutton(c),         
                    { 
                        {
                            container(awful.titlebar.widget.ontopbutton(c)),
                            container(awful.titlebar.widget.stickybutton(c)),
                            layout  = wibox.layout.flex.horizontal
                        },
                        left = dpi(1),
                        right = dpi(3),
                        widget = wibox.container.margin
                    }, 
                    -- awful.titlebar.widget.floatingbutton (c),
                    -- buttons = buttons,
                    --awful.titlebar.widget.iconwidget(c),

                    layout  = titlebar_item_layout
                },
                { -- Middle
                    --{ -- Title
                        --align  = beautiful.titlebar_title_align,
                        --widget = title_widget
                    --},
                    title_widget,
                    buttons = buttons,
                    layout  = wibox.layout.flex.horizontal
                },
                { -- Right
                    -- awful.titlebar.widget.stickybutton   (c),
                    -- awful.titlebar.widget.ontopbutton    (c),
                    pad(1),
                    container(awful.titlebar.widget.minimizebutton(c)),
                    container(awful.titlebar.widget.maximizedbutton(c)),
                    container(awful.titlebar.widget.closebutton(c)),
       
                    -- buttons = buttons,
                    layout = titlebar_item_layout
                },
                layout = titlebar_layout
                --layout = wibox.layout.align.horizontal
            }
        end
    end
end)

return titlebars
