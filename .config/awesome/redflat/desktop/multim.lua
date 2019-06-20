-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat multi monitoring deskotp widget                                       --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-- Pack of corner indicators and two lines with dashbar, label and text
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local dcommon = require("redflat.desktop.common")
local system = require("redflat.system")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local multim = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		barpack      = {},
		corner       = { width = 40 },
		state_height = 60,
		digit_num    = 3,
		prog_height  = 100,
		labels       = {},
		image_gap    = 20,
		unit         = { { "MB", - 1 }, { "GB", 1024 } },
		color        = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "desktop.multim") or {})
end

local default_geometry = { width = 200, height = 100, x = 100, y = 100 }
local default_args = {
	corners = { num = 1, maxm = 1},
	lines   = { maxm = 1 },
	meter   = { func = system.dformatted.cpumem },
	timeout = 60,
}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function set_info(value, args, corners, lines, icon, last_state, style)
	local corners_alert = value.alert

	-- set dashbar values and color
	for i, line in ipairs(args.lines) do
		lines:set_values(value.lines[i][1] / line.maxm, i)
		lines:set_text(redutil.text.dformat(value.lines[i][2], line.unit or style.unit, style.digit_num), i)

		if line.crit then
			local cc = value.lines[i][1] > line.crit and style.color.main or style.color.gray
			lines:set_text_color(cc, i)
			if style.labels[i] then lines:set_label_color(cc, i) end
		end
	end

	-- set corners value
	for i = 1, args.corners.num do
		local v = value.corners[i] or 0
		corners:set_values(v / args.corners.maxm, i)
		if args.corners.crit then corners_alert = corners_alert or v > args.corners.crit end
	end

	-- colorize icon if needed
	if style.image and corners_alert ~= last_state then
		icon:set_color(corners_alert and style.color.main or style.color.gray)
		last_state = corners_alert
	end
end


-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function multim.new(args, geometry, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local icon
	local last_state

	local args = redutil.table.merge(default_args, args or {})
	local geometry = redutil.table.merge(default_geometry, geometry or {})
	local style = redutil.table.merge(default_style(), style or {})

	local barpack_style = redutil.table.merge(style.barpack, { dashbar = { color = style.color } })
	local corner_style = redutil.table.merge(style.corner, { color = style.color })

	-- Create wibox
	--------------------------------------------------------------------------------
	dwidget.wibox = wibox({ type = "desktop", visible = true, bg = style.color.wibox })
	dwidget.wibox:geometry(geometry)

	-- Construct layouts
	--------------------------------------------------------------------------------
	local lines = dcommon.barpack(#args.lines, barpack_style)
	local corners = dcommon.cornerpack(args.corners.num, corner_style)
	lines.layout:set_forced_height(style.state_height)

	if style.image then
		icon = svgbox(style.image)
		icon:set_color(style.color.gray)
	end

	dwidget.wibox:setup({
		{
			icon and wibox.container.margin(icon, 0, style.image_gap),
			corners.layout,
			nil,
			forced_height = style.prog_height,
			layout = wibox.layout.align.horizontal()
		},
		nil,
		lines.layout,
		layout = wibox.layout.align.vertical
	})

	for i, label in ipairs(style.labels) do
		lines:set_label(label, i)
	end

	-- Update info function
	--------------------------------------------------------------------------------
	local function get_and_set(source)
		local state = args.meter.func(source)
		set_info(state, args, corners, lines, icon, last_state, style)
	end

	local function update_plain()
		get_and_set(args.meter.args)
	end

	local function update_async()
		awful.spawn.easy_async(args.async, get_and_set)
	end

	local update = args.async and update_async or update_plain

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = args.timeout })
	t:connect_signal("timeout", update)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return dwidget
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function multim.mt:__call(...)
	return multim.new(...)
end

return setmetatable(multim, multim.mt)
