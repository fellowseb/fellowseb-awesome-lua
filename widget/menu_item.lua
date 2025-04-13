local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

MENU_ITEM = {}

--- @alias menu_item_state "active" | "inactive"
--- @alias menu_item_hover_state "off" | "hover"

--- Create a menu item
--- @return menu_item
MENU_ITEM.create = function(args)
	args = args or {}

	--- @class menu_item
	local menu_item = {
		label = args.label or "",
		state = args.state or "inactive",
		hover_state = args.hover_state or "off",
		widget = wibox.widget({
			expand = "outside",
			layout = wibox.layout.align.horizontal,
		}),
		on_click = args.on_click or function() end,
		icon = args.icon or nil,
	}

	if menu_item.icon ~= nil then
		menu_item.icon.resize = true
		menu_item.icon.forced_width = 40
		menu_item.icon.forced_height = 40
		menu_item.icon = wibox.container.place(menu_item.icon, "center", "center")
	end

	-- Methods

	-- Update the widget based on state changes
	function menu_item:update()
		self.widget:reset()
		local bg_color = "#FFFFFF00"
		if self.state == "active" then
			bg_color = "#FFFFFF44"
		else
			if self.hover_state == "hover" then
				bg_color = "#FFFFFF22"
			end
		end
		self.widget:setup({
			{
				{
					{
						widget = self.icon or wibox.widget.imagebox(),
					},
					layout = wibox.container.margin,
					left = 10,
					right = 10,
				},
				{
					text = self.label,
					widget = wibox.widget.textbox,
					forced_height = dpi(30),
					font = "Terminus Bold 16",
				},
				expand = "inside",
				layout = wibox.layout.align.horizontal,
			},
			bg = bg_color,
			widget = wibox.container.background,
		})
	end

	menu_item.widget:connect_signal("button::release", function()
		menu_item.on_click()
	end)
	menu_item.widget:connect_signal("mouse::enter", function()
		menu_item.hover_state = "hover"
		menu_item:update()
	end)
	menu_item.widget:connect_signal("mouse::leave", function()
		menu_item.hover_state = "off"
		menu_item:update()
	end)

	menu_item:update()

	return menu_item
end

return MENU_ITEM
