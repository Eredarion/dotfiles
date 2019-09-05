local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad


local popup_shape = function(cr, width, height)
  gears.shape.rounded_rect (cr, width, height, 6)
end

local tasklist = awful.widget.tasklist {
        screen   = screen[1],
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        style    = {
            shape = popup_shape,
        },
        layout   = {
            spacing = dpi(0),
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
          {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = dpi(10),
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            forced_width    = dpi(60),
            forced_height   = dpi(60),
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects) --luacheck: no unused
                self:get_children_by_id('clienticon')[1].client = c
            end,
          },
        top = dpi(20),
        bottom = dpi(14),
        right = dpi(7),
        left = dpi(7),
        widget  = wibox.container.margin
        },
}

local task_name =  wibox.widget {
    fg     = beautiful.xforeground,
    font   = text_font .. " medium 11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox()
}

local text_container = wibox.widget {
    task_name,
    left = dpi(20),
    right = dpi(20),
    bottom = dpi(20),
    widget  = wibox.container.margin
}

local layout_popup = awful.popup {
    widget = {
        {   
            tasklist,
            align = "center",
            valign = "center",
            widget  = wibox.container.place
        },
        text_container,
        layout = wibox.layout.fixed.vertical
    },
    placement      = awful.placement.centered,
    shape          = popup_shape,
    minimum_width  = dpi(250),
    minimum_height = dpi(80),
    ontop          = true,
    visible        = false,
    bg             = beautiful.xbackgroundtp,
}


local set_client_boder = function ( size )
    local tt = awful.screen.focused().selected_tag:clients()
    for Index, client in pairs( tt ) do
        if count > 1 then
            client.border_width = dpi(size)
        end
    end
end


awful.keygrabber {
    start_callback = function()
            --local t = awful.screen.focused().selected_tag
            local taskes = awful.screen.focused().selected_tag:clients()
            count = 0
            for Index, Value in pairs( taskes ) do
                count = count + 1
            end
            if count > 1 then
                layout_popup.visible = true  
            end
            text_container.forced_width = count * 3

    end,    
    stop_callback  = function() 
            layout_popup.visible = false
            --set_client_boder(0)
        end,
    export_keybindings = true,
    stop_event = "release",
    stop_key = "Mod4",
    keybindings = {
        {{  "Mod4"         }, "Tab", function()
            if count > 1 then
                awful.client.focus.byidx(1)
                --set_client_boder(2)
                task_name.markup = "<span color=\"" .. beautiful.xforeground .. "\">" .. client.focus.name .. "</span>"
            end
        end},
        {{ "Mod4", "Shift" } , 'Tab' , function()
             awful.client.focus.byidx(-1)
        end},
        -- {{ "Mod4", "Shift" } , 'q' , function()
        --      client.focus:kill()
        -- end},
    }
}

return layout_popup