-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat upgrades widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Show if system updates available using apt-get
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local string = string

local beautiful = require("beautiful")
local awful = require("awful")
local timer = require("gears.timer")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local upgrades = { objects = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = redutil.base.placeholder(),
		notify      = {},
		firstrun    = false,
		need_notify = true,
		color       = { main = "#b1222b", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.upgrades") or {})
end

-- Create a new upgrades widget
-- @param style Table containing colors and geometry parameters for all elemets
-- @param update_timeout Update interval
-----------------------------------------------------------------------------------------------------------------------
function upgrades.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local object = {}
	local args = args or {}
	local update_timeout = args.update_timeout or 3600
	local command = args.command or [[bash -c 'apt-get upgrade -s | grep -P "^\d+ upgraded" | cut -d " " -f1']]
	local force_notify = false
	local style = redutil.table.merge(default_style(), style or {})

	object.widget = svgbox(style.icon)
	object.widget:set_color(style.color.icon)
	table.insert(upgrades.objects, object)

	-- Set tooltip
	--------------------------------------------------------------------------------
	object.tp = tooltip({ objects =  { object.widget } }, style.tooltip)

	-- Update info function
	--------------------------------------------------------------------------------
	local function update_count(output)
		local c = string.match(output, "(%d+)")
		object.tp:set_text(c .. " updates")

		local color = tonumber(c) > 0 and style.color.main or style.color.icon
		object.widget:set_color(color)

		if style.need_notify and (tonumber(c) > 0 or force_notify) then
			rednotify:show(redutil.table.merge({ text = c .. " updates available" }, style.notify))
		end
	end

	function object.update(args)
		local args = args or {}
		force_notify = args.is_force
		awful.spawn.easy_async(command, update_count)
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = update_timeout })
	t:connect_signal("timeout", object.update)
	t:start()

	if style.firstrun then t:emit_signal("timeout") end

	--------------------------------------------------------------------------------
	return object.widget
end

-- Update upgrades info for every widget
-----------------------------------------------------------------------------------------------------------------------
function upgrades:update(is_force)
	for _, o in ipairs(upgrades.objects) do o.update({ is_force = is_force }) end
end

-- Config metatable to call upgrades module as function
-----------------------------------------------------------------------------------------------------------------------
function upgrades.mt:__call(...)
	return upgrades.new(...)
end

return setmetatable(upgrades, upgrades.mt)
