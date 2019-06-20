-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat appswitcher widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Advanced application switcher
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ Familiar Alt Tab by Joren Heit
------ https://github.com/jorenheit/awesome_alttab
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local type = type
local math = math
local unpack = unpack
local table = table

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")
local gears = require("gears")
local naughty = require("naughty")

local pixbuf
local function load_pixbuf()
	local Gdk = require("lgi").Gdk
	pixbuf = require("lgi").GdkPixbuf
end
local is_pixbuf_loaded = pcall(load_pixbuf)

local dfparser = require("redflat.service.dfparser")
local redutil = require("redflat.util")
local redtip = require("redflat.float.hotkeys")
local redtitle = require("redflat.titlebar")
local rectshape = require("gears.shape").rectangle

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local appswitcher = { clients_list = {}, index = 1, hotkeys = {}, svgsize = 256, keys = {} }

local cache = { border_color = nil }
local svgcache = {}
local _empty_surface = redutil.base.placeholder({ txt = " " })

-- key bindings
appswitcher.keys.move = {
	{
		{}, "Right", function() appswitcher:switch() end,
		{ description = "Select next app", group = "Navigation" }
	},
	{
		{}, "Left", function() appswitcher:switch({ reverse = true }) end,
		{ description = "Select previous app", group = "Navigation" }
	},
}

appswitcher.keys.action = {
	{
		{}, "Return", function() appswitcher:hide() end,
		{ description = "Activate and exit", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

appswitcher.keys.all = awful.util.table.join(appswitcher.keys.move, appswitcher.keys.action)

appswitcher._fake_keys = {
	{
		{}, "N", nil,
		{ description = "Select app by key", group = "Navigation" }
	},
}


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		wibox_height    = 200,
		label_height    = 20,
		title_height    = 30,
		icon_size       = 48,
		preview_gap     = 20,
		preview_format  = 16/10,
		preview_margin  = { 15, 15, 15, 15 },
		border_margin   = { 5, 5, 0, 5 },
		border_width    = 0,
		parser          = {},
		update_timeout  = 0.1,
		min_icon_number = 2,
		keytip          = { geometry = { width = 400, height = 320 }, exit = false },
		title_font      = "Iosevka Medium 10",
		hotkeys         = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
		font            = { font = "Iosevka Medium ", size = 14, face = 0, slant = 0 },
		color           = { border = "#04090E", text = "#e4eceb", main = "#D8AB9E", preview_bg = "#0b1015",
		                    wibox  = "#04090E", icon = "#e4eceb", bg   = "#0b1015", gray = "#e4eceb" },
		shape           = rectshape
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "float.appswitcher") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Create icon visual for client
--------------------------------------------------------------------------------
local function get_icon_visual(icon_db, c, size)
	local surface, buf

	if icon_db[string.lower(c.class)] then
		local icon = icon_db[string.lower(c.class)]

		if type(icon) == "string" and string.match(icon, "%.svg") and is_pixbuf_loaded then
			if svgcache[icon] then
				buf = svgcache[icon]
			else
				buf = pixbuf.Pixbuf.new_from_file_at_scale(icon, size, size, true)
				svgcache[icon] = buf
			end
		else
			surface = gears.surface(icon)
		end
	else
		surface = c.icon and gears.surface(c.icon) or _empty_surface
	end

	return surface, buf
end

-- Find all clients to be shown
--------------------------------------------------------------------------------
local function clients_find(filter)
	local clients = {}
	for i, c in ipairs(client.get()) do
		if not (c.skip_taskbar or c.hidden or c.type == "splash" or c.type == "dock" or c.type == "desktop")
		and filter(c, mouse.screen) then
			table.insert(clients, c)
		end
	end
	return clients
end

-- Loop iterating through table
--------------------------------------------------------------------------------
local function iterate(tabl, i, diff)
	local nxt = i + diff

	if nxt > #tabl then nxt = 1
	elseif nxt < 1 then nxt = #tabl end

	return nxt
end

-- Select new focused window
--------------------------------------------------------------------------------
local function focus_and_raise(c)
	if c.minimized then c.minimized = false end

	if not c:isvisible() then
		awful.tag.viewmore(c:tags(), c.screen)
	end

	client.focus = c
	c:raise()
end

-- Initialize appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:init()

	-- Initialize style vars
	--------------------------------------------------------------------------------
	local style = default_style()
	local icon_db = dfparser.icon_list(style.parser)
	local iscf = 1 -- icon size correction factor

	self.keytip = style.keytip
	self._fake_keys[1][4].keyset = style.hotkeys
	self:set_keys()

	-- Create floating wibox for appswitcher widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	-- Keygrabber
	--------------------------------------------------------------------------------
	local function focus_by_key(key)
		self:switch({ index = awful.util.table.hasitem(style.hotkeys, key) })
	end

	self.keygrabber = function(mod, key, event)
		if event == "press" then return false end

		for _, k in ipairs(self.keys.all) do
			if redutil.key.match_grabber(k, mod, key) then k[3](); return false end
		end

		if awful.util.table.hasitem(style.hotkeys,   key) then focus_by_key(key) end
	end

	-- Function to form title string for given client (name and tags)
	--------------------------------------------------------------------------------
	function self.title_generator(c)
		local client_tags = {}

		for _, t in ipairs(c:tags()) do
			client_tags[#client_tags + 1] = string.upper(t.name)
		end

		local tag_text = string.format('<span color="%s">[%s]</span>', style.color.gray, table.concat(client_tags, " "))

		return string.format("%s %s", awful.util.escape(c.name) or "Untitled", tag_text)
	end

	-- Function to mark window (border color change)
	--------------------------------------------------------------------------------
	function self.winmark(c, mark)
		if mark then
			cache.border_color = c.border_color
			c.border_color = style.color.main
		else
			c.border_color = cache.border_color
		end
	end

	-- Function to correct wibox size for given namber of icons
	--------------------------------------------------------------------------------
	function self.size_correction(inum)
		local w, h
		local inum = math.max(inum, style.min_icon_number)
		local expen_h = (inum - 1) * style.preview_gap + style.preview_margin[1] + style.preview_margin[2]
		                + style.border_margin[1] + style.border_margin[2]
		local expen_v = style.label_height + style.preview_margin[3] + style.preview_margin[4] + style.title_height
		                + style.border_margin[3] + style.border_margin[4]

		-- calculate width
		local widget_height = style.wibox_height - expen_v + style.label_height
		local max_width = screen[mouse.screen].geometry.width - 2 * self.wibox.border_width
		local wanted_width = inum * ((widget_height - style.label_height) * style.preview_format) + expen_h

		-- check if need size correction
		if wanted_width <= max_width then
			-- correct width
			w = wanted_width
			h = style.wibox_height
			iscf = 1
		else
			-- correct height
			local wanted_widget_width = (max_width - expen_h) / inum
			local corrected_height = wanted_widget_width / style.preview_format + expen_v

			w = max_width
			h = corrected_height
			iscf = (corrected_height - expen_v) / (style.wibox_height - expen_v)
		end

		-- set wibox size
		self.wibox:geometry({ width = w, height = h })
	end

	-- Create custom widget to draw previews
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- Fit
	------------------------------------------------------------
	function widg:fit(context, width, height) return width, height end

	-- Draw
	------------------------------------------------------------
	function widg.draw(widg, context, cr, width, height)

		-- calculate preview pattern size
		local psize = {
			width = (height - style.label_height) * style.preview_format,
			height = (height - style.label_height)
		}

		-- Shift pack of preview icons to center of widget if needed
		if #self.clients_list < style.min_icon_number then
			local tr = (style.min_icon_number - #self.clients_list) * (style.preview_gap + psize.width) / 2
			cr:translate(tr, 0)
		end

		-- draw all previews
		for i = 1, #self.clients_list do

			-- support vars
			local sc, tr, surface, pixbuf
			local c = self.clients_list[i]

			-- create surface and calculate scale and translate factors
			if c:isvisible() then
				surface = gears.surface(c.content)
				local cg = c:geometry()

				if cg.width/cg.height > style.preview_format then
					sc = psize.width / cg.width
					tr = {0, (psize.height - sc * cg.height) / 2}
				else
					sc = psize.height / cg.height
					tr = {(psize.width - sc * cg.width) / 2, 0}
				end
			else
				-- surface = gears.surface(icon_db[string.lower(c.class)] or c.icon)
				surface, pixbuf = get_icon_visual(icon_db, c, self.svgsize)

				-- sc = style.icon_size / surface.width * iscf
				sc = style.icon_size / (surface and surface.width or pixbuf.width) * iscf
				tr = {(psize.width - style.icon_size * iscf) / 2, (psize.height - style.icon_size * iscf) / 2}
			end

			-- translate cairo for every icon
			if i > 1 then cr:translate(style.preview_gap + psize.width, 0) end

			-- draw background for preview
			cr:set_source(gears.color(i == self.index and style.color.main or style.color.preview_bg))
			cr:rectangle(0, 0, psize.width, psize.height)
			cr:fill()

			-- draw current preview or application icon
			cr:save()
			cr:translate(unpack(tr))
			cr:scale(sc, sc)

			if pixbuf then
				cr:set_source_pixbuf(pixbuf, 0, 0)
			else
				cr:set_source_surface(surface, 0, 0)
			end
			cr:paint()
			cr:restore()

			-- draw label
			local txt = style.hotkeys[i] or "?"
			cr:set_source(gears.color(i == self.index and style.color.main or style.color.text))
			redutil.cairo.set_font(cr, style.font)
			redutil.cairo.textcentre.horizontal(cr, { psize.width/2, psize.height + style.label_height }, txt)
		end

		collectgarbage() -- prevents memory leak after complex draw function
	end

	-- Set widget and create title for wibox
	--------------------------------------------------------------------------------
	self.widget = widg

	self.titlebox = wibox.widget.textbox("TEXT")
	self.titlebox:set_align("center")
	self.titlebox:set_font(style.title_font)

	local title_layout = wibox.container.constraint(self.titlebox, "exact", nil, style.title_height)
	local vertical_layout = wibox.layout.fixed.vertical()
	local widget_bg = wibox.container.background(
		wibox.container.margin(self.widget, unpack(style.preview_margin)),
		style.color.bg
	)
	vertical_layout:add(title_layout)
	vertical_layout:add(widget_bg)

	self.wibox:set_widget(wibox.container.margin(vertical_layout, unpack(style.border_margin)))

	-- Set preview icons update timer
	--------------------------------------------------------------------------------
	self.update_timer = timer({ timeout = style.update_timeout })
	self.update_timer:connect_signal("timeout", function() self.widget:emit_signal("widget::updated") end)

	-- Restart switcher if any client was closed
	--------------------------------------------------------------------------------
	client.connect_signal("unmanage",
		function(c)
			if self.wibox.visible and awful.util.table.hasitem(self.clients_list, c) then
				self:hide(true)
				self:show(cache.args)
			end
		end
	)
end

-- Show appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:show(args)

	local args = args or {}
	local filter = args.filter
	local noaction = args.noaction

	if not self.wibox then self:init() end
	if self.wibox.visible then
		self:switch(args)
		return
	end

	local clients = clients_find(filter)
	if #clients == 0 then return end

	self.clients_list = clients
	self.cutted = redtitle.cut_all(clients)
	cache.args = args
	self.size_correction(#clients)
	redutil.placement.centered(self.wibox, nil, mouse.screen.workarea)
	self.update_timer:start()
	awful.keygrabber.run(self.keygrabber)

	self.index = awful.util.table.hasitem(self.clients_list, client.focus) or 1
	self.winmark(self.clients_list[self.index], true)
	self.titlebox:set_markup(self.title_generator(self.clients_list[self.index]))
	-- if not noaction then self:switch(args) end
	self.widget:emit_signal("widget::updated")

	self.wibox.visible = true

	redtip:set_pack(
		"Appswitcher", self.tip, self.keytip.column, self.keytip.geometry,
		self.keytip.exit and  function() appswitcher:hide(true) end
	)
end

idex = function(index) 
	if ( index == 0 or index == 1 ) then
		return 1
    else 
    	return index
    end
end

-- Hide appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:hide(is_empty_call)

	if not self.wibox then self:init() end
	if not self.wibox.visible then return end
	self.wibox.visible = false
	-- redtip:remove_pack()
	self.update_timer:stop()
	redtitle.restore_all(self.cutted)
	awful.keygrabber.stop(self.keygrabber)

	self.winmark(self.clients_list[self.index], false)
	if not is_empty_call then focus_and_raise(self.clients_list[self.index]) end
end

-- Toggle appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:switch(args)
	local args = args or {}
	self.winmark(self.clients_list[self.index], false)

	if args.index then
		if self.clients_list[args.index] then self.index = args.index end
	else
		local reverse = args.reverse or false
		local diff = reverse and -1 or 1
		self.index = iterate(self.clients_list, self.index, diff)
	end

	self.winmark(self.clients_list[self.index], true)
	self.titlebox:set_markup("<span color=\'" .. beautiful.xforeground .. "\' >" .. self.title_generator(self.clients_list[self.index]) .. "</span>")
	self.widget:emit_signal("widget::updated")
end

-- Set user hotkeys
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:set_keys(keys, layout)
	local layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.move, self.keys.action) end
	end

	self.tip = awful.util.table.join(self.keys.all, self._fake_keys)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return appswitcher