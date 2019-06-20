-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat barvalue widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Complex indicator with progress bar and label on top of it
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
--local beautiful = require("beautiful")

local dcommon = require("redflat.desktop.common")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local barvalue = { mt = {} }

-- Create a new barvalue widget
-- @param dashbar_style Style variables for redflat dashbar
-- @param label_style Style variables for redflat textbox
-----------------------------------------------------------------------------------------------------------------------
function barvalue.new(dashbar_style, label_style)

	local widg = {}

	-- construct layout with indicators
	local progressbar = dcommon.dashbar(dashbar_style)
	local label = dcommon.textbox(nil, label_style)

	widg.layout = wibox.widget({
		label, nil, progressbar,
		layout = wibox.layout.align.vertical,
	})

	-- setup functions
	function widg:set_text(text)
		label:set_text(text)
	end

	function widg:set_value(x)
		progressbar:set_value(x)
	end

	return widg
end

-- Config metatable to call barvalue module as function
-----------------------------------------------------------------------------------------------------------------------
function barvalue.mt:__call(...)
	return barvalue.new(...)
end

return setmetatable(barvalue, barvalue.mt)
