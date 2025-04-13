local lgi = require("lgi")
local cairo = lgi.cairo
local Rsvg = lgi.Rsvg

ICON = {}

--- @return Rsvg
function ICON.get_svg_handle(path, color)
	local file, err_msg = io.open(path, "r")
	if file == nil then
		error("Failed to load SVG file " .. path .. " (" .. err_msg .. ")")
	end
	local content_str = file:read("*a")
	if type(content_str) ~= "string" then
		error("Unexpected SVG file content type")
	end
	content_str = string.gsub(content_str, "currentColor", color)
	file:close()
	local svg_handle = Rsvg.Handle.new_from_data(content_str)
	return svg_handle
end

function ICON.svg_surf(path, color)
	local img = cairo.ImageSurface(cairo.Format.ARGB32, 24, 24)
	-- 10, 10 are width and height
	local cr = cairo.Context(img)
	ICON.get_svg_handle(path, color):render_cairo(cr)
	return img
end

return ICON
