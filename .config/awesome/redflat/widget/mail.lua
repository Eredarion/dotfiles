-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat mail widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Check if new mail available using python scripts or curl shell command
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local tonumber = tonumber

local awful = require("awful")
local beautiful = require("beautiful")
local timer = require("gears.timer")

local rednotify = require("redflat.float.notify")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local mail = { objects = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = redutil.base.placeholder(),
		notify      = {},
		need_notify = true,
		firstrun    = false,
		color       = { main = "#b1222b", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.mail") or {})
end

-- Mail check functions
-----------------------------------------------------------------------------------------------------------------------
mail.check_function = {}

mail.check_function["script"] = function(args)
	return args.script
end

mail.check_function["curl_imap"] = function(args)
	local port = args.port or 993
	local request = "-X 'STATUS INBOX (UNSEEN)'"
	local head_command = "curl --connect-timeout 5 -fsm 5"

	local curl_req = string.format("%s --url imaps://%s:%s/INBOX -u %s:%s %s -k",
	                               head_command, args.server, port, args.mail, args.password, request)

	return curl_req
end
-- Create a new mail widget
-- @param style Table containing colors and geometry parameters for all elemets
-- @param args.update_timeout Update interval
-- @param args.path Folder with mail scripts
-- @param args.scripts Table with scripts name
-----------------------------------------------------------------------------------------------------------------------
function mail.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local count
	local object = {}
	local update_timeout = args.update_timeout or 3600
	local maillist = args.maillist or {}

	local style = redutil.table.merge(default_style(), style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	object.widget = svgbox(style.icon)
	object.widget:set_color(style.color.icon)
	table.insert(mail.objects, object)

	-- Set tooltip
	--------------------------------------------------------------------------------
	object.tp = tooltip({ objects = { object.widget } }, style.tooltip)
	object.tp:set_text("0 new messages")

	-- Update info function
	--------------------------------------------------------------------------------
	local function mail_count(output)
		local c = tonumber(string.match(output, "%d+"))

		if c then
			count = count + c
			if style.need_notify and count > 0 then
				rednotify:show(redutil.table.merge({ text = count .. " new messages" }, style.notify))
			end
		end

		local color = count > 0 and style.color.main or style.color.icon
		object.widget:set_color(color)
		object.tp:set_text(count .. " new messages")
	end

	function object.update()
		count = 0
		for _, cmail in ipairs(maillist) do
			awful.spawn.easy_async(mail.check_function[cmail.checker](cmail), mail_count)
		end
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

-- Update mail info for every widget
-----------------------------------------------------------------------------------------------------------------------
function mail:update()
	for _, o in ipairs(mail.objects) do o.update() end
end

-- Config metatable to call mail module as function
-----------------------------------------------------------------------------------------------------------------------
function mail.mt:__call(...)
	return mail.new(...)
end

return setmetatable(mail, mail.mt)
