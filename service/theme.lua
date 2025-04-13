--- Utilities to handle awesomewm themes
--- @meta
local theme = {}

local THEME_STORAGE_KEY = "appearence_theme"

--- Factory function to create a theme_service
--- @param deps { storage: storage }
--- @return theme_service
theme.create_theme_service = function(deps)
	--- @class theme_service
	local theme_service = {}
	local storage = deps.storage
	--- Get current theme
	--- @return string current_theme
	function theme_service:get_current_theme()
		return storage:get(THEME_STORAGE_KEY)
	end
	--- Set current theme
	--- @param new_theme string
	function theme_service:set_current_theme(new_theme)
		storage:set(THEME_STORAGE_KEY, new_theme)
	end
	--- List available themes
	--- @return table themes
	function theme_service:list_themes()
		local file = io.popen("ls /home/seb/.config/awesome/themes", "r")
		if file == nil then
			error("Failed to list available themes")
		end
		local themes_str = file:read("*a")
		local themes = {}
		file:close()
		for theme in string.gmatch(themes_str, "[a-zA-Z0-9-_]*") do
			if string.len(theme) > 0 then
				table.insert(themes, theme)
			end
		end
		return themes
	end
	return theme_service
end

return theme
