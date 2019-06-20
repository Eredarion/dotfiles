-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat volume indicator widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Indicator with audio icon
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local reddash = require("redflat.gauge.graph.dash")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local audio = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width   = 100,
		icon    = redutil.base.placeholder(),
		dash    = {},
		dmargin = { 10, 0, 0, 0 },
		color   = { icon = "#a0a0a0", mute = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.audio.blue") or {})
end

-- Create a new audio widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function audio.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- Construct widget
	--------------------------------------------------------------------------------
	local icon = svgbox(style.icon)
	local dash = reddash(style.dash)

	local layout = wibox.layout.fixed.horizontal()
	layout:add(icon)
	layout:add(wibox.container.margin(dash, unpack(style.dmargin)))

	local widg = wibox.container.constraint(layout, "exact", style.width)

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x) dash:set_value(x) end

	function widg:set_mute(mute)
		icon:set_color(mute and style.color.mute or style.color.icon)
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call audio module as function
-----------------------------------------------------------------------------------------------------------------------
function audio.mt:__call(...)
	return audio.new(...)
end

return setmetatable(audio, audio.mt)
