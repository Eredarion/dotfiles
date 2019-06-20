-- RedFlat util submodule

local math = math
local string = string

local text = {}

-- Functions
-----------------------------------------------------------------------------------------------------------------------

-- Format string to number with minimum length
------------------------------------------------------------
function text.oformat(v, w)
	local p = math.ceil(math.log10(v))
	local prec = v <= 10 and w - 1 or p > w and 0 or w - p
	return string.format('%.' .. prec .. 'f', v)
end

-- Format output for destop widgets
------------------------------------------------------------
function text.dformat(value, unit, w, spacer)
	local res = value
	local add = ""
	local w = w or 3
	local spacer = spacer or "  "

	for _, v in pairs(unit) do
		if value > v[2] then
			res = math.abs(value/v[2])
			add = v[1]
		end
	end

	return text.oformat(res, w) .. spacer .. add
end


-- End
-----------------------------------------------------------------------------------------------------------------------
return text

