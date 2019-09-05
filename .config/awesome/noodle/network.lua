local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local helpers = require("helpers")
local pad = helpers.pad
local lain  = require("lain")

-- Construct layouts
--------------------------------------------------------------------------------

local notyfi_shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, 6)
end

-- Progressbar
------------------------------------------------------------
local bar = wibox.widget {
    value         = 100,
    max_value     = 100,
    forced_height = dpi(5),
    forced_width  = dpi(215),
    color     = beautiful.xcolor1,
    background_color = beautiful.xcolor8 .. "33",
    shape         = notyfi_shape,
    bar_shape   = notyfi_shape,
    widget        = wibox.widget.progressbar
}

local bar_upload = wibox.widget {
    value         = 100,
    max_value     = 100,
    forced_height = dpi(5),
    forced_width  = dpi(215),
    color     = beautiful.xcolor2,
    background_color = beautiful.xcolor8 .. "33",
    shape         = notyfi_shape,
    bar_shape   = notyfi_shape,
    widget        = wibox.widget.progressbar
}
------------------------------------------------------------


-- Image
------------------------------------------------------------
local box_image = wibox.widget.imagebox()
box_image.image = os.getenv("HOME") .. "/.config/awesome/themes/skyfall/icons/download.svg"

local image_upload = wibox.widget.imagebox()
image_upload.image = os.getenv("HOME") .. "/.config/awesome/themes/skyfall/icons/upload.svg"
------------------------------------------------------------

local graph_shape = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 1)
end

-- Graph
------------------------------------------------------------
local graph_widget_upload = wibox.widget {
    max_value = 40,
    step_width = 3,
    step_spacing = 0,
    forced_height = dpi(18),
    forced_width = bar_upload.width,
    background_color = "#00000000",
    color = beautiful.xcolor2,
    step_shape = graph_shape,
    widget = wibox.widget.graph
}

local graph_widget = wibox.widget {
    max_value = 500,
    step_width = 3,
    step_spacing = 0,
    forced_height = dpi(18),
    forced_width = bar.width,
    background_color = "#00000000",
    color = beautiful.xcolor1,
    step_shape = graph_shape,
    widget = wibox.widget.graph
}
------------------------------------------------------------


-- Net
------------------------------------------------------------
local netupinfo = lain.widget.net({
    settings = function()
        -- if iface ~= "network off" and
        --    string.match(theme.weather.widget.text, "N/A")
        -- then
        --     theme.weather.update()
        -- end
        graph_widget_upload:add_value(tonumber(net_now.sent))
        graph_widget:add_value(tonumber(net_now.received))
        widget:set_markup(net_now.sent .. " ")
    end
})
------------------------------------------------------------


-- Received
------------------------------------------------------------
local align_vertical = wibox.layout.align.vertical()
align_vertical:set_top(nil)
align_vertical:set_middle(wibox.container.margin(graph_widget, dpi(0), dpi(0), 0, 0))
align_vertical:set_bottom(wibox.container.constraint(bar, "exact", nil, dpi(4)))
local area = wibox.layout.fixed.horizontal()
area:add(box_image)
area:add(pad(1))
area:add(wibox.container.margin(align_vertical, dpi(8), dpi(8), 0, 0))
area:add(pad(1))
------------------------------------------------------------


-- Upload
------------------------------------------------------------
local align_vertical_upload = wibox.layout.align.vertical()
align_vertical_upload:set_top(nil)
align_vertical_upload:set_middle(wibox.container.margin(graph_widget_upload, dpi(0), dpi(0), 0, 0))
align_vertical_upload:set_bottom(wibox.container.constraint(bar_upload, "exact", nil, dpi(4)))
local area_upload = wibox.layout.fixed.horizontal()
area_upload:add(image_upload)
area_upload:add(pad(1))
area_upload:add(wibox.container.margin(align_vertical_upload, dpi(8), dpi(8), 0, 0))
area_upload:add(pad(1))
------------------------------------------------------------


-- Widgets
------------------------------------------------------------
local main_wd = wibox.widget {
  area,
  forced_height = dpi(24),
  widget = wibox.container.margin
}

local main_wd_upload = wibox.widget {
  area_upload,
  forced_height = dpi(24),
  widget = wibox.container.margin
}

local network = wibox.widget{
        {
            main_wd,
            bottom = dpi(12),
            widget = wibox.container.margin
        },
    main_wd_upload,
    layout = wibox.layout.fixed.vertical
}
------------------------------------------------------------


return network
