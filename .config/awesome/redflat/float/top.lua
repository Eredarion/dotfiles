-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat top widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with list of top processes
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")

local redutil = require("redflat.util")
local system = require("redflat.system")
local decoration = require("redflat.float.decoration")
local redtip = require("redflat.float.hotkeys")
local rectshape = require("gears.shape").rectangle


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local top = { keys = {} }

-- key bindings
top.keys.action = {
	{
		{}, "c", function() top:set_sort("cpu") end,
		{ description = "Sort by CPU usage", group = "Action" }
	},
	{
		{}, "m", function() top:set_sort("mem") end,
		{ description = "Sort by RAM usage", group = "Action" }
	},
	{
		{}, "k", function() top.kill_selected() end,
		{ description = "Kill process", group = "Action" }
	},
	{
		{}, "Escape", function() top:hide() end,
		{ description = "Close top list widget", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

top.keys.all = awful.util.table.join({}, top.keys.action)

top._fake_keys = {
	{
		{}, "N", nil,
		{ description = "Select process by key", group = "Action",
		  keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }
	},
}


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		timeout       = 2,
		screen_gap    = 0,
		set_position  = nil,
		geometry      = { width = 460, height = 380 },
		border_margin = { 10, 10, 10, 10 },
		labels_width  = { 30, 70, 120 },
		title_height  = 48,
		list_side_gap = 8,
		border_width  = 2,
		bottom_height = 80,
		button_margin = { 140, 140, 22, 22 },
		keytip        = { geometry = { width = 400, height = 300 } },
		title_font    = "Sans 14 bold",
		unit          = { { "KB", -1 }, { "MB", 1024 }, { "GB", 1024^2 } },
		color         = { border = "#575757", text = "#aaaaaa", highlight = "#eeeeee", main = "#b1222b",
		                  bg = "#161616", bg_second = "#181818", wibox = "#202020" },
		shape         = rectshape

	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "float.top") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Sort functions
--------------------------------------------------------------------------------
local function sort_by_cpu(a, b)
	return a.pcpu > b.pcpu
end

local function sort_by_mem(a, b)
	return a.mem > b.mem
end

-- Fuction to build list item
--------------------------------------------------------------------------------
local function construct_item(style)
	local item = {}
	item.label = {
		number = wibox.widget.textbox(),
		name   = wibox.widget.textbox(),
		cpu    = wibox.widget.textbox(),
		mem    = wibox.widget.textbox()
	}

	item.label.cpu:set_align("right")
	item.label.mem:set_align("right")

	local bg = style.color.bg

	-- Construct item layouts
	------------------------------------------------------------
	local mem_label_with_gap = wibox.container.margin(item.label.mem, 0, style.list_side_gap)
	local num_label_with_gap = wibox.container.margin(item.label.number, style.list_side_gap)

	local right = wibox.layout.fixed.horizontal()
	right:add(wibox.container.constraint(item.label.cpu, "exact", style.labels_width[2], nil))
	right:add(wibox.container.constraint(mem_label_with_gap, "exact", style.labels_width[3], nil))

	local middle = wibox.layout.align.horizontal()
	middle:set_left(item.label.name)

	local left = wibox.container.constraint(num_label_with_gap, "exact", style.labels_width[1], nil)

	local item_horizontal  = wibox.layout.align.horizontal()
	item_horizontal:set_left(left)
	item_horizontal:set_middle(middle)
	item_horizontal:set_right(right)
	item.layout = wibox.container.background(item_horizontal, bg)

	-- item functions
	------------------------------------------------------------
	function item:set_bg(color)
		bg = color
		item.layout:set_bg(color)
	end

	function item:set_select()
		item.layout:set_bg(style.color.main)
		item.layout:set_fg(style.color.highlight)
	end

	function item:set_unselect()
		item.layout:set_bg(bg)
		item.layout:set_fg(style.color.text)
	end

	function item:set(args)
		if args.number then item.label.number:set_text(args.number) end
		if args.name then item.label.name:set_text(args.name) end
		if args.cpu then item.label.cpu:set_text(args.cpu) end
		if args.mem then item.label.mem:set_text(args.mem) end
		if args.pid then item.pid = args.pid end
	end

	------------------------------------------------------------
	return item
end

-- Fuction to build top list
--------------------------------------------------------------------------------
local function list_construct(n, style, select_function)
	local list = {}

	local list_layout = wibox.layout.flex.vertical()
	list.layout = wibox.container.background(list_layout, style.color.bg)

	list.items = {}
	for i = 1, n do
		list.items[i] = construct_item(style)
		list.items[i]:set({ number = i})
		list.items[i]:set_bg((i % 2) == 1 and style.color.bg or style.color.bg_second)
		list_layout:add(list.items[i].layout)

		list.items[i].layout:buttons(awful.util.table.join(
			awful.button({ }, 1, function() select_function(i) end)
		))
	end

	return list
end

-- Initialize top widget
-----------------------------------------------------------------------------------------------------------------------
function top:init()

	-- Initialize vars
	--------------------------------------------------------------------------------
	local number_of_lines = 9 -- number of lines in process list
	local selected = {}
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local style = default_style()
	local sort_function, title, toplist

	self.style = style

	-- Select process function
	--------------------------------------------------------------------------------
	local function select_item(i)
		if selected.number and selected.number ~= i then toplist.items[selected.number]:set_unselect() end
		toplist.items[i]:set_select()
		selected.pid = toplist.items[i].pid
		selected.number = i
	end

	-- Set sorting rule
	--------------------------------------------------------------------------------
	function self:set_sort(args)
		if args == "cpu" then
			sort_function = sort_by_cpu
			title:set({ cpu = "↓CPU", mem = "Memory"})
		elseif args == "mem" then
			sort_function = sort_by_mem
			title:set({ cpu = "CPU", mem = "↓Memory"})
		end
	end

	-- Kill selected process
	--------------------------------------------------------------------------------
	function self.kill_selected()
		if selected.number then awful.spawn.with_shell("kill " .. selected.pid) end
		self:update_list()
	end

	-- Widget keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if     event ~= "press" then return end
		for _, k in ipairs(self.keys.all) do
			if redutil.key.match_grabber(k, mod, key) then k[3](); return end
		end
		if string.match("123456789", key) then select_item(tonumber(key)) end
	end

	-- Build title
	--------------------------------------------------------------------------------
	title = construct_item(style)
	title:set_bg(style.color.wibox)
	title:set({ number = "#", name = "Process Name", cpu = "↓ CPU", mem = "Memory"})

	for _, txtbox in pairs(title.label) do
		txtbox:set_font(style.title_font)
	end

	title.label.cpu:buttons(awful.util.table.join(
		awful.button({ }, 1, function() self:set_sort("cpu") end)
	))
	title.label.mem:buttons(awful.util.table.join(
		awful.button({ }, 1, function() self:set_sort("mem") end)
	))

	-- Build top list
	--------------------------------------------------------------------------------
	toplist = list_construct(number_of_lines, style, select_item)

	-- Update function
	--------------------------------------------------------------------------------
	function self:update_list()
		local proc = system.proc_info(cpu_storage)
		table.sort(proc, sort_function)

		if selected.number then
			toplist.items[selected.number]:set_unselect()
			selected.number = nil
		end

		for i = 1, number_of_lines do
			toplist.items[i]:set({
				name = proc[i].name,
				cpu = string.format("%.1f", proc[i].pcpu * 100),
				--mem = string.format("%.0f", proc[i].mem) .. " MB",
				mem = redutil.text.dformat(proc[i].mem, style.unit, 2, " "),
				pid = proc[i].pid
			})

			if selected.pid and selected.pid == proc[i].pid then
				toplist.items[i]:set_select()
				selected.number = i
			end
		end
	end

	-- Construct widget layouts
	--------------------------------------------------------------------------------
	local buttonbox = wibox.widget.textbox("Kill")

	local button_widget = decoration.button(buttonbox, self.kill_selected)

	local button_layout = wibox.container.margin(button_widget, unpack(style.button_margin))
	local bottom_area = wibox.container.constraint(button_layout, "exact", nil, style.bottom_height)

	local area = wibox.layout.align.vertical()
	area:set_top(wibox.container.constraint(title.layout, "exact", nil, style.title_height))
	area:set_middle(toplist.layout)
	area:set_bottom(bottom_area)
	local list_layout = wibox.container.margin(area, unpack(style.border_margin))

	-- Create floating wibox for top widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})

	self.wibox:set_widget(list_layout)
	self.wibox:geometry(style.geometry)

	-- Update timer
	--------------------------------------------------------------------------------
	self.update_timer = timer({timeout = style.timeout})
	self.update_timer:connect_signal("timeout", function() self:update_list() end)

	-- First run actions
	--------------------------------------------------------------------------------
	self:set_keys()
	self:set_sort("cpu")
	self:update_list()
end

-- Hide top widget
-----------------------------------------------------------------------------------------------------------------------
function top:hide()
	self.wibox.visible = false
	self.update_timer:stop()
	awful.keygrabber.stop(self.keygrabber)
	redtip:remove_pack()
end

-- Show top widget
-----------------------------------------------------------------------------------------------------------------------
function top:show(srt)
	if not self.wibox then self:init() end
	if self.wibox.visible then
		top:hide()
	else
		if srt then self:set_sort(srt) end
		self:update_list()

		if self.style.set_position then
			self.wibox:geometry(self.style.set_position())
		else
			awful.placement.under_mouse(self.wibox)
		end
		redutil.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)

		self.wibox.visible = true
		self.update_timer:start()
		awful.keygrabber.run(self.keygrabber)

		redtip:set_pack("Top process", self.tip, self.style.keytip.column, self.style.keytip.geometry)
	end
end

-- Set user hotkeys
-----------------------------------------------------------------------------------------------------------------------
function top:set_keys(keys, layout)
	local layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join({}, self.keys.action) end
	end

	self.tip = awful.util.table.join(self.keys.all, self._fake_keys)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return top
