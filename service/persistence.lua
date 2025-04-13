local lyaml = require("lyaml")
local io = require("io")

--- Utilities to persist state to a file-based database
--- @meta
persistence = {}

--- Key-Value storage using a YAML file
--- @param args { path: string }
--- @return storage
persistence.create_storage = function(args)
	--- @class storage
	local storage = {
		--- Path to the database file in YAML format
		path = args.path,
		--- Table of values
		values = {},
	}
	--- Writes all values to the file
	--- @private
	local function write()
		local file = io.open(storage.path, "w")
		if file == nil then
			error("Failed to open db file for writing at" .. storage.path)
		end
		local content_str = lyaml.dump({ storage.values })
		file:write(content_str)
		file:close()
	end
	--- Load values from file
	--- @public
	function storage:load()
		local file, errmsg = io.open(self.path, "r")
		if file == nil then
			error("Failed to open db file at" .. self.path .. ": " .. errmsg)
		end
		local content = file:read("*a")
		file:close()
		local parsed_persisted_file = lyaml.load(content)
		self.values = parsed_persisted_file
	end
	-- Get a value
	--- @public
	--- @return unknown
	function storage:get(key)
		return self.values[key]
	end
	-- Set a value. Writes to the file.
	--- @public
	--- @param key string
	--- @param value string | number | boolean
	function storage:set(key, value)
		self.values[key] = value
		write()
	end
	return storage
end

return persistence
