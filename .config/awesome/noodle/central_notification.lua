local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local timer   = require("gears.timer")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

local N = {}


-- Progressbar
------------------------------------------------------------
local icon = wibox.widget {
    align  = 'center',
    valign = 'center',
    --image = beautiful.reboot_icon,
    forced_height = dpi(180),
    forced_width  = dpi(180),
    widget = wibox.widget.imagebox
}
------------------------------------------------------------


-- Progressbar
------------------------------------------------------------
local notyfi_shape = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, 6)
end

local progressbar = wibox.widget {
	value         = value,
    forced_height = dpi(8),
    forced_width  = dpi(180),
    color		  = beautiful.xcolor3,
    background_color = beautiful.xcolor8 .. "66",
    shape         = notyfi_shape,
    bar_shape	  = notyfi_shape,
    widget        = wibox.widget.progressbar
}
------------------------------------------------------------


-- Create popup
------------------------------------------------------------
local notyfi = awful.popup {
    widget = {
        {
            icon,
            progressbar,
            layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(10),
        widget  = wibox.container.margin
    },
    y            = awful.screen.focused().geometry.height / 2,
    x            = (awful.screen.focused().geometry.width / 2) - (dpi(200) / 2),
    shape        = notyfi_shape,
    bg           = beautiful.xbackgroundtp,
    type		 = "dock",
    ontop        = true,
    visible      = false,
}

-- Create timer
local timer_die = timer { timeout = 1.5 }

-- Show popup
local function show ( image, value, color)
	icon.image = image
	progressbar.value = value / 100
	progressbar.color = color
	if timer_die.started then
		timer_die:again()
	else
		timer_die:start()
	end
	notyfi.visible = true
end

-- Hide popup after timeout
timer_die:connect_signal("timeout", function()
			notyfi.visible = false
            -- Prevent infinite timers events on errors.
            if timer_die.started then
                timer_die:stop()
            end
        end)


N.show = show
------------------------------------------------------------

function light_control(value)
    awful.spawn.easy_async_with_shell("xbacklight " .. value .. " ; xbacklight -get", function(stdout)
        awesome.emit_signal("brightness_changed")
        local light = stdout:match'[^.]*'
        show(beautiful.redshift_icon, tonumber(light), "#FDC198")
        collectgarbage()
    end)
end


return N
