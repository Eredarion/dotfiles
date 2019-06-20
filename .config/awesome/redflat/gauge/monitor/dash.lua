-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with dash indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dashmon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width = 40,
		line  = { num = 5, width = 4 },
		color = { main = "#b1222b", urgent = "#00725b", gray = "#575757" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.monitor.dash") or {})
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function dashmon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		value = 0,
		width = style.width,
		color = style.color.main,
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		data.value = x < 1 and x or 1
		self:emit_signal("widget::updated")
	end

	function widg:set_width(width)
		data.width = width
		self:emit_signal("widget::updated")
	end

	function widg:set_alert(alert)
		data.color = alert and style.color.urgent or style.color.main
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		if data.width then
			return data.width, height
		else
			local size = math.min(width, height)
			return size, size
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)

		local gap = (height - style.line.width * style.line.num) / (style.line.num - 1)
		local dy = style.line.width + gap
		local p = math.ceil(style.line.num * data.value)

		for i = 1, style.line.num do
			cr:set_source(color(i <= p and data.color or style.color.gray))
			cr:rectangle(0, height - (i - 1) * dy, width, - style.line.width)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function dashmon.mt:__call(...)
	return dashmon.new(...)
end

return setmetatable(dashmon, dashmon.mt)
