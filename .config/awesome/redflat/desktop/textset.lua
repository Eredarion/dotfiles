-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat desktop text widget                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Text widget with text update function
-----------------------------------------------------------------------------------------------------------------------

local setmetatable = setmetatable

local textbox = require("wibox.widget.textbox")
local beautiful = require("beautiful")
local timer = require("gears.timer")
local awful = require("awful")

local lgi = require("lgi")
local Pango = lgi.Pango

local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local textset = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		font  = "Sans 12",
		spacing = 0,
		color = { gray = "#525252" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.textset") or {})
end

-- Create a textset widget. It draws the time it is in a textbox.
-- @param format The time format. Default is " %a %b %d, %H:%M ".
-- @param timeout How often update the time. Default is 60.
-- @return A textbox widget
-----------------------------------------------------------------------------------------------------------------------
function textset.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local funcarg = args.arg or {}
	local timeout = args.timeout or { 60 }
	local actions = args.actions or {}
	local style = redutil.table.merge(default_style(), style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = textbox()
	widg:set_font(style.font)
	widg:set_valign("top")

	-- Some pivate properties of awesome textbox v4.0
	widg._private.layout:set_justify(true)
	widg._private.layout:set_spacing(Pango.units_from_double(style.spacing))

	-- data setup
	local data = {}
	local timers = {}
	for i = 1, #actions do data[i] = "" end

	-- update info function
	local function update()
		local state = {}
		for _, txt in ipairs(data) do state[#state + 1] = txt end
		widg:set_markup(string.format('<span color="%s">%s</span>', style.color.gray, table.concat(state)))
	end

	-- Set update timers
	--------------------------------------------------------------------------------
	for i, action in ipairs(actions) do
		timers[i] = timer({ timeout = timeout[i] or timeout[1] })
		if args.acync then
			timers[i]:connect_signal("timeout", function()
				awful.spawn.easy_async(args.acync[i], function(o) data[i] = action(o); update() end)
			end)
		else
			timers[i]:connect_signal("timeout", function()
				data[i] = action(funcarg[i])
				update()
			end)
		end
		timers[i]:start()
		timers[i]:emit_signal("timeout")
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call textset module as function
-----------------------------------------------------------------------------------------------------------------------
function textset.mt:__call(...)
	return textset.new(...)
end

return setmetatable(textset, textset.mt)
