--- A collection of utilities uses for debugging purposes
--- @meta
local debug = {}

--- Creates a string representation of any object for debugging purposes
--- @param obj unknown
--- @return string dump_str
debug.dump = function(obj)
	if type(obj) == "table" then
		local s = "{ "
		for k, v in pairs(obj) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. debug.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(obj)
	end
end

return debug
