-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat separatoe widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Simple graphical separator to decorate panel
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local unpack = unpack
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local separator = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		marginv = { 0, 0, 0, 0 },
		marginh = { 0, 0, 0, 0 },
		color  = { shadow1 = "#141414", shadow2 = "#313131" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.separator") or {})
end

-- Create a new separator widget
-- Total size two pixels bigger than sum of margins for general direction
-----------------------------------------------------------------------------------------------------------------------
local function separator_base(horizontal, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	if not style.margin then
		style.margin = horizontal and style.marginh or style.marginv
	end

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		if horizontal then
			return width, 2
		else
			return 2, height
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width, height)
		cr:set_source(color(style.color.shadow1))
		if horizontal then cr:rectangle(0, 0, width, 1)
		else cr:rectangle(0, 0, 1, height) end
		cr:fill()

		cr:set_source(color(style.color.shadow2))
		if horizontal then cr:rectangle(0, 1, width, 1)
		else cr:rectangle(1, 0, 1, height) end
		cr:fill()
	end

	--------------------------------------------------------------------------------
	return wibox.container.margin(widg, unpack(style.margin))
end

-- Horizontal and vertial variants
-----------------------------------------------------------------------------------------------------------------------
function separator.vertical(style)
	return separator_base(false, style)
end

function separator.horizontal(style)
	return separator_base(true, style)
end

-----------------------------------------------------------------------------------------------------------------------
return separator
