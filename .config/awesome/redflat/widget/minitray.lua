-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat minitray                                                    --
-----------------------------------------------------------------------------------------------------------------------
-- Tray located on separate wibox
-- minitray:toggle() used to show/hide wibox
-- Widget with graphical counter to show how many apps placed in the system tray
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ minitray
------ http://awesome.naquadah.org/wiki/Minitray
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local redutil = require("redflat.util")
local dotcount = require("redflat.gauge.graph.dots")
local tooltip = require("redflat.float.tooltip")
local rectshape = require("gears.shape").rectangle

-- Initialize tables and wibox
-----------------------------------------------------------------------------------------------------------------------
local minitray = { widgets = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		dotcount     = {},
		geometry     = { height = 40 },
		set_position = nil,
		screen_gap   = 0,
		border_width = 2,
		double_wibox = false,
		show_delay   = 0.05,
		color        = { wibox = "#202020", border = "#575757" },
		shape        = rectshape
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.minitray") or {})
end

-- Initialize minitray floating window
-----------------------------------------------------------------------------------------------------------------------
function minitray:init(style)

	-- Create wibox for tray
	--------------------------------------------------------------------------------
	local wargs = {
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	}

	self.wibox = wibox(wargs)

	-- dirty workaround for sowe tray background problems
	if style.double_wibox then
		self.wibox_bg = wibox(wargs)
		self.show_with_delay = timer({
			timeout = style.show_delay,
			callback = function() self.wibox.visible = true; self.show_with_delay:stop() end
		})
	end

	self.wibox:geometry(style.geometry)

	self.geometry = style.geometry
	self.screen_gap = style.screen_gap
	self.set_position = style.set_position

	-- Create tooltip
	--------------------------------------------------------------------------------
	self.tp = tooltip({}, style.tooltip)

	-- Set tray
	--------------------------------------------------------------------------------
	local l = wibox.layout.align.horizontal()
	self.tray = wibox.widget.systray()
	l:set_middle(self.tray)
	self.wibox:set_widget(l)

	-- update geometry if tray icons change
	self.tray:connect_signal('widget::redraw_needed', function()
		self:update_geometry()
	end)
end

-- Show/hide functions for wibox
-----------------------------------------------------------------------------------------------------------------------

-- Update Geometry
--------------------------------------------------------------------------------
function minitray:update_geometry()

	-- Set wibox size and position
	------------------------------------------------------------
	local items = awesome.systray()
	if items == 0 then items = 1 end

	self.wibox:geometry({ width = self.geometry.width or self.geometry.height * items })

	if self.set_position then
		self.wibox:geometry(self.set_position())
	else
		awful.placement.under_mouse(self.wibox)
	end

	redutil.placement.no_offscreen(self.wibox, self.screen_gap, mouse.screen.workarea)
end

-- Show
--------------------------------------------------------------------------------
function minitray:show()
	self:update_geometry()
	if self.wibox_bg then
		self.wibox_bg:geometry(self.wibox:geometry())
		self.wibox_bg.visible = true
		self.show_with_delay:start()
	else
		self.wibox.visible = true
	end

end

-- Hide
--------------------------------------------------------------------------------
function minitray:hide()
	self.wibox.visible = false
	if self.wibox_bg then self.wibox_bg.visible = false end
end

-- Toggle
--------------------------------------------------------------------------------
function minitray:toggle()
	if self.wibox.visible then
		self:hide()
	else
		self:show()
	end
end

-- Create a new tray widget
-- @param args.timeout Update interval
-- @param style Settings for dotcount widget
-----------------------------------------------------------------------------------------------------------------------
function minitray.new(_, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
--	local args = args or {} -- usesless now, leave it be for backward compatibility and future cases
	local style = redutil.table.merge(default_style(), style or {})

	-- Initialize minitray window
	--------------------------------------------------------------------------------
	if not minitray.wibox then
		minitray:init(style)
	end

	-- Create tray widget
	--------------------------------------------------------------------------------
	local widg = dotcount(style.dotcount)
	table.insert(minitray.widgets, widg)

	-- Set tooltip
	--------------------------------------------------------------------------------
	minitray.tp:add_to_object(widg)

	-- Set update timer
	--------------------------------------------------------------------------------
	function widg:update()
		local appcount = awesome.systray()
		self:set_num(appcount)
		minitray.tp:set_text(appcount .. " apps")
	end

	minitray.tray:connect_signal('widget::redraw_needed', function() widg:update() end)

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call minitray module as function
-----------------------------------------------------------------------------------------------------------------------
function minitray.mt:__call(...)
	return minitray.new(...)
end

return setmetatable(minitray, minitray.mt)
