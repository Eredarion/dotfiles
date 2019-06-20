-- RedFlat util submodule

local wibox = require("wibox")

local desktop = {}

-- Functions
-----------------------------------------------------------------------------------------------------------------------
local function sum(t, n)
	local s = 0
	local n = n or #t
	for i = 1, n do s = s + t[i] end
	return s
end

local function wposition(grid, n, workarea, dir)
	local total = sum(grid[dir])
	local full_gap = sum(grid.edge[dir])
	local gap = #grid[dir] > 1 and (workarea[dir] - total - full_gap) / (#grid[dir] - 1) or 0

	local current = sum(grid[dir], n - 1)
	local pos = grid.edge[dir][1] + (n - 1) * gap + current

	return pos
end

-- Calculate size and position for desktop widget
------------------------------------------------------------
function desktop.wgeometry(grid, place, workarea)
	return {
		x = wposition(grid, place[1], workarea, "width"),
		y = wposition(grid, place[2], workarea, "height"),
		width  = grid.width[place[1]],
		height = grid.height[place[2]]
	}
end

-- Edge constructor
------------------------------------------------------------
function desktop.edge(direction, zone)
	local edge = { area = {} }

	edge.wibox = wibox({
		bg      = "#00000000",  -- transparent without compositing manager
		opacity = 0,            -- transparent with compositing manager
		ontop   = true,
		visible = true
	})

	edge.layout = wibox.layout.fixed[direction]()
	edge.wibox:set_widget(edge.layout)

	if zone then
		for i, z in ipairs(zone) do
			edge.area[i] = wibox.container.margin(nil, 0, 0, z)
			edge.layout:add(edge.area[i])
		end
	end

	return edge
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return desktop

