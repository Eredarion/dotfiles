-----------------------------------------------------------------------------------------------------------------------
--                                   RedFlat pulseaudio volume control widget                                        --
-----------------------------------------------------------------------------------------------------------------------
-- Indicate and change volume level using pacmd
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ Pulseaudio volume control
------ https://github.com/orofarne/pulseaudio-awesome/blob/master/pulseaudio.lua
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local math = math
local table = table
local tonumber = tonumber
local string = string
local setmetatable = setmetatable
local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")
local naughty = require("naughty")

local tooltip = require("redflat.float.tooltip")
local audio = require("redflat.gauge.audio.blue")
local rednotify = require("redflat.float.notify")
local redutil = require("redflat.util")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local pulse = { widgets = {}, mt = {} }
local counter = 0

pulse.startup_time = 4

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		notify      = {},
		widget      = audio.new,
		audio       = {}
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.pulse") or {})
end

local change_volume_default_args = {
	down        = false,
	step        = 655 * 5,
	show_notify = false
}

-- Change volume level
-----------------------------------------------------------------------------------------------------------------------
function pulse:change_volume(args)

	-- initialize vars
	local args = redutil.table.merge(change_volume_default_args, args or {})
	local diff = args.down and -args.step or args.step

	-- get current volume
	local v = redutil.read.output("pacmd dump |grep set-sink-volume | grep " .. self.def_sink )
	local parsed = string.match(v, "0x%x+")

	-- catch possible problems with pacmd output
	if not parsed then
		naughty.notify({ title = "Warning!", text = "PA widget can't parse pacmd output" })
		return
	end

	local volume = tonumber(parsed)

	-- calculate new volume
	local new_volume = volume + diff

	if new_volume > 65536 then
		new_volume = 65536
	elseif new_volume < 0 then
		new_volume = 0
	end

	-- show notify if need
	if args.show_notify then
		local vol = new_volume / 65536
		rednotify:show(
			redutil.table.merge({ value = vol, text = string.format('%.0f', vol*100) .. "%" }, pulse.notify)
		)
	end

	-- set new volume
	awful.spawn("pacmd set-sink-volume " .. self.def_sink .. " " .. new_volume)
	-- update volume indicators
	self:update_volume()
end

-- Set mute
-----------------------------------------------------------------------------------------------------------------------
function pulse:mute()
	local mute = redutil.read.output("pacmd dump | grep set-sink-mute | grep " .. self.def_sink)

	if string.find(mute, "no", -4) then
		awful.spawn("pacmd set-sink-mute " .. self.def_sink .. " yes")
	else
		awful.spawn("pacmd set-sink-mute " .. self.def_sink .. " no")
	end
	self:update_volume()
end

-- Update volume level info
-----------------------------------------------------------------------------------------------------------------------
function pulse:update_volume()

	-- initialize vars
	local volmax = 65536
	local volume = 0

	-- get current volume and mute state
	local v = redutil.read.output("pacmd dump | grep set-sink-volume | grep " .. self.def_sink)
	local m = redutil.read.output("pacmd dump | grep set-sink-mute | grep " .. self.def_sink)

	if v then
		local pv = string.match(v, "0x%x+")
		if pv then volume = math.floor(tonumber(pv) * 100 / volmax) end
	end

	local mute = not (m and string.find(m, "no", -4))

	-- update tooltip
	self.tooltip:set_text(volume .. "%")

	-- update widgets value
	for _, w in ipairs(pulse.widgets) do
		w:set_value(volume/100)
		w:set_mute(mute)
	end
end

-- Update default pulse sink
-----------------------------------------------------------------------------------------------------------------------
function pulse:update_sink()
	self.def_sink = redutil.read.output("pacmd dump|perl -ane 'print $F[1] if /set-default-sink/'")
end

-- Create a new pulse widget
-- @param timeout Update interval
-----------------------------------------------------------------------------------------------------------------------
function pulse.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	pulse.notify = style.notify

	local args = args or {}
	local timeout = args.timeout or 5
	local autoupdate = args.autoupdate or false
	pulse:update_sink()

	-- create widget
	--------------------------------------------------------------------------------
	local widg = style.widget(style.audio)
	table.insert(pulse.widgets, widg)

	-- Set tooltip
	--------------------------------------------------------------------------------
	if not pulse.tooltip then
		pulse.tooltip = tooltip({ objects = { widg } }, style.tooltip)
	else
		pulse.tooltip:add_to_object(widg)
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	if autoupdate then
		local t = timer({ timeout = timeout })
		t:connect_signal("timeout", function() pulse:update_volume() end)
		t:start()
	end

	--------------------------------------------------------------------------------
	pulse:update_volume()
	return widg
end

-- Set startup timer
-- This is workaround if module activated bofore pulseaudio servise start
-----------------------------------------------------------------------------------------------------------------------
pulse.startup_updater = timer({ timeout = 1 })
pulse.startup_updater:connect_signal("timeout",
	function()
		counter = counter + 1
		pulse:update_sink()
		pulse:update_volume()
		if counter > pulse.startup_time then pulse.startup_updater:stop() end
	end
)
pulse.startup_updater:start()

-- Config metatable to call pulse module as function
-----------------------------------------------------------------------------------------------------------------------
function pulse.mt:__call(...)
	return pulse.new(...)
end

return setmetatable(pulse, pulse.mt)