-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat titlebar                                                   --
-----------------------------------------------------------------------------------------------------------------------
-- model titlebar with two view: light and full
-- Only simple indicators avaliable, no buttons
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.titlebar v3.5.2
------ (c) 2012 Uli Schlachter
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local error = error
local table = table


local awful = require("awful")
local beautiful = require("beautiful")
local drawable = require("wibox.drawable")
local color = require("gears.color")
local wibox = require("wibox")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = { mt = {}, widget = {} }
titlebar.list = setmetatable({}, { __mode = 'k' })


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		size          = 8,
		position      = "top",
		icon          = { size = 20, gap = 10, angle = 0 },
		font          = "Sans 12 bold",
		border_margin = { 0, 0, 0, 4 },
		color         = { main = "#b1222b", wibox = "#202020", gray = "#575757", text = "#aaaaaa" }
	}

	return redutil.table.merge(style, beautiful.titlebar or {})
end


-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get titlebar function
------------------------------------------------------------
local function get_titlebar_function(c, position)
	if     position == "left"   then return c.titlebar_left
	elseif position == "right"  then return c.titlebar_right
	elseif position == "top"    then return c.titlebar_top
	elseif position == "bottom" then return c.titlebar_bottom
	else
		error("Invalid titlebar position '" .. position .. "'")
	end
end

-- Get titlebar model
------------------------------------------------------------
function titlebar.get_model(c, position)
	local position = position or "top"
	return titlebar.list[c] and titlebar.list[c][position] or nil
end

-- Get titlebar style
------------------------------------------------------------
function titlebar.get_style()
	return default_style()
end

-- Get titlebar client list
------------------------------------------------------------
function titlebar.get_clients()
	local cl = {}
	for c, _ in pairs(titlebar.list) do table.insert(cl, c) end
	return cl
end


-- Build client titlebar
-----------------------------------------------------------------------------------------------------------------------
function titlebar.new(c, style)
	if not titlebar.list[c] then titlebar.list[c] = {} end
	local style = redutil.table.merge(default_style(), style or {})

	-- Make sure that there is never more than one titlebar for any given client
	local ret
	if not titlebar.list[c][style.position] then
		local tfunction = get_titlebar_function(c, style.position)
		local d = tfunction(c, style.size)

		local context = { client = c, position = style.position }
		local base = wibox.container.margin(nil, unpack(style.border_margin))

		ret = drawable(d, context, "redbar")
		ret:_inform_visible(true)
		ret:set_bg(style.color.wibox)

		-- add info to model
		local model = {
			layouts = {},
			current = nil,
			style = style,
			size = style.size,
			drawable = ret,
			hidden = false,
			cutted = false,
			tfunction = tfunction,
			base = base,
		}

		-- set titlebar base layout
		ret:set_widget(base)

		-- save titlebar info
		titlebar.list[c][style.position] = model
		c:connect_signal("unmanage", function() ret:_inform_visible(false) end)
	else
		ret = titlebar.list[c][style.position].drawable
	end

	return ret
end

-- Titlebar functions
-----------------------------------------------------------------------------------------------------------------------

-- Show client titlebar
------------------------------------------------------------
function titlebar.show(c, position)
	local model = titlebar.get_model(c, position)
	if model and model.hidden then
		model.tfunction(c, model.size)
		model.hidden = false
	end
end

-- Hide client titlebar
------------------------------------------------------------
function titlebar.hide(c, position)
	local model = titlebar.get_model(c, position)
	if model and not model.hidden then
		model.tfunction(c, 0)
		model.hidden = true
	end
end

-- Toggle client titlebar
------------------------------------------------------------
function titlebar.toggle(c, position)
	local model = titlebar.get_model(c, position)
	if not model then return end

	model.tfunction(c, model.hidden and model.size or 0)
	model.hidden = not model.hidden
end

-- Add titlebar view model
------------------------------------------------------------
function titlebar.add_layout(c, position, layout, size)
	local model = titlebar.get_model(c, position)
	if not model then return end

	local size = size or model.style.size
	local l = { layout = layout, size = size }
	table.insert(model.layouts, l)

	if not model.current then
		model.base:set_widget(layout)
		model.current = 1
		if model.size ~= size then
			model.tfunction(c, size)
			model.size = size
		end
	end
end

-- Switch titlebar view model
------------------------------------------------------------
function titlebar.switch(c, position)
	local model = titlebar.get_model(c, position)
	if not model or #model.layouts == 1 then return end

	model.current = (model.current < #model.layouts) and (model.current + 1) or 1
	local layout = model.layouts[model.current]

	model.base:set_widget(layout.layout)
	if model.size ~= layout.size then
		model.tfunction(c, layout.size)
		model.size = layout.size
	end
end


-- Titlebar mass actions
-----------------------------------------------------------------------------------------------------------------------

-- Temporary hide client titlebar
------------------------------------------------------------
function titlebar.cut_all(cl, position)
	local cl = cl or titlebar.get_clients()
	local cutted = {}
	for _, c in ipairs(cl) do
		local model = titlebar.get_model(c, position)
		if model and not model.hidden and not model.cutted then
			model.tfunction(c, 0)
			model.cutted = true
			table.insert(cutted, c)
		end
	end
	return cutted
end

-- Restore client titlebar if it was cutted
------------------------------------------------------------
function titlebar.restore_all(cl, position)
	local cl = cl or titlebar.get_clients()
	for _, c in ipairs(cl) do
		local model = titlebar.get_model(c, position)
		if model and not model.hidden then
			model.tfunction(c, model.size)
			model.cutted = false
		end
	end
end

-- Mass actions
------------------------------------------------------------
function titlebar.toggle_all(cl, position)
	local cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.toggle(c, position) end
end

function titlebar.switch_all(cl, position)
	local cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.switch(c, position) end
end

function titlebar.show_all(cl, position)
	local cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.show(c, position) end
end

function titlebar.hide_all(cl, position)
	local cl = cl or titlebar.get_clients()
	for _, c in pairs(cl) do titlebar.hide(c, position) end
end


-- Titlebar indicators
-----------------------------------------------------------------------------------------------------------------------
titlebar.icon = {}

function titlebar.icon.base(_, style)
	local style = redutil.table.merge(default_style(), style or {})
--	local sigpack = sigpack or {}

	-- local data
	local data = {
		color = style.color.gray
	}

	-- build widget
	local widg = wibox.widget.base.make_widget()

	function widg:fit(_, _, width, height)
		return width, height
	end

	function widg:draw(_, cr, width, height)
		local d = math.tan(style.icon.angle) * height

		cr:set_source(color(data.color))
		cr:move_to(0, height)
		cr:rel_line_to(d, - height)
		cr:rel_line_to(width - d, 0)
		cr:rel_line_to(-d, height)
		cr:close_path()

		cr:fill()
	end

	-- user function
	function widg:set_active(active)
		data.color = active and style.color.main or style.color.gray
		self:emit_signal("widget::updated")
	end

	-- widget width setup
	widg:set_forced_width(style.icon.size)

	return widg
end

-- Client property indicator
------------------------------------------------------------
function titlebar.icon.property(c, prop, style)
	local w = titlebar.icon.base(c, style)
	w:set_active(c[prop])
	c:connect_signal("property::" .. prop, function() w:set_active(c[prop]) end)
	return w
end

-- Client focus indicator
------------------------------------------------------------
function titlebar.icon.focus(c, style)
	local w = titlebar.icon.base(c, style)
	c:connect_signal("focus", function() w:set_active(true) end)
	c:connect_signal("unfocus", function() w:set_active(false) end)
	return w
end

-- Client name indicator
------------------------------------------------------------
function titlebar.icon.label(c, style)
	local style = redutil.table.merge(default_style(), style or {})
	local w = wibox.widget.textbox()
	w:set_font(style.font)
	w:set_align("center")

	local function update()
		local txt = awful.util.escape(c.name or "Unknown")
		w:set_markup(string.format('<span color="%s">%s</span>', style.color.text, txt))
	end
	c:connect_signal("property::name", update)
	update()

	return w
end

-- Remove from list on close
-----------------------------------------------------------------------------------------------------------------------
client.connect_signal("unmanage", function(c) titlebar.list[c] = nil end)


-- Config metatable to call titlebar module as function
-----------------------------------------------------------------------------------------------------------------------
function titlebar.mt:__call(...)
	return titlebar.new(...)
end

return setmetatable(titlebar, titlebar.mt)
