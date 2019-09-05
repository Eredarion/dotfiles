local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi


local popup_shape = function(cr, width, height)
  gears.shape.rounded_rect (cr, width, height, 6)
end


local ll = awful.widget.layoutlist {
    source      = awful.widget.layoutlist.source.default_layouts, --DOC_HIDE
    spacing = dpi(24),
    base_layout = wibox.widget {
        spacing         = dpi(24),
        forced_num_cols = 3,
        layout          = wibox.layout.grid.vertical,
    },
    style = {
        bg_selected    = beautiful.bar_background,
        shape_selected = popup_shape,
    },
    widget_template = {
        {
            {
                id            = 'icon_role',
                widget        = wibox.widget.imagebox,
            },
            margins = dpi(5),
            widget  = wibox.container.margin,
        },
        id              = 'background_role',
        forced_width    = dpi(60),
        forced_height   = dpi(60),
        shape           = gears.shape.rounded_rect,
        widget          = wibox.container.background,
    },
}

local layout_popup = awful.popup {
    widget = wibox.widget {
        ll,
        margins = dpi(20),
        widget  = wibox.container.margin,
    },
    placement    = awful.placement.centered,
    shape        = popup_shape,
    ontop        = true,
    visible      = false,
    bg           = beautiful.xbackgroundtp,
}

function gears.table.iterate_value(t, value, step_size, filter, start_at)
    local k = gears.table.hasitem(t, value, true, start_at)
    if not k then return end

    step_size = step_size or 1
    local new_key = gears.math.cycle(#t, k + step_size)

    if filter and not filter(t[new_key]) then
        for i=1, #t do
            local k2 = gears.math.cycle(#t, new_key + i)
            if filter(t[k2]) then
                return t[k2], k2
            end
        end
        return
    end

    return t[new_key], new_key
end


awful.keygrabber {
    start_callback = function() layout_popup.visible = true  end,
    stop_callback  = function() layout_popup.visible = false end,
    export_keybindings = true,
    stop_event = "release",
    stop_key = "Mod1",
    keybindings = {
        {{  "Mod1"         }, "Tab", function()
             awful.layout.set(gears.table.iterate_value(ll.layouts, ll.current_layout, 1), nil)
        end},
        {{ "Mod1", "Shift" } , 'Tab' , function()
             awful.layout.set(gears.table.iterate_value(ll.layouts, ll.current_layout, -1), nil)
        end},
    }
}

return layout_popup