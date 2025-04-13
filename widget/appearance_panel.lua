-- Widget: Appearence Settings Panel
-- fellowseb.widget.appearance_panel

local gshape = require("gears.shape")
local wibox = require("wibox")

--- Factory function to create an appearance_panel widget
--- @param deps {theme_service: theme_service, awesome: awesome }
local function factory(deps, args)
	args = args or {}
	local theme_service = deps.theme_service
	local awesome = deps.awesome

	-- Instance
	local appearance_panel = {
		widget = wibox.widget({
			layout = wibox.layout.grid,
		}),
	}

	-- Methods

	-- Update the widget based on state changes
	function appearance_panel:update()
		local available_themes = theme_service.list_themes()
		local current_theme = theme_service:get_current_theme()
		local theme_widgets = {}
		for _, theme_name in pairs(available_themes) do
			local cb = function()
				theme_service:set_current_theme(theme_name)
				awesome.restart()
				naughty.notify({
					preset = naughty.config.presets.normal,
					title = "Settings > Appearence",
					text = "Theme changed successfully",
				})
			end
			local checkbox_widget = wibox.widget({
				widget = wibox.widget.checkbox,
				forced_width = 30,
				forced_height = 30,
				checked = current_theme == theme_name,
				check_shape = gshape.rounded_rect,
				shape = gshape.rounded_rect,
			})
			checkbox_widget:connect_signal("button::release", cb)
			local label_widget = wibox.widget({
				{
					text = theme_name,
					widget = wibox.widget.textbox,
					valign = "center",
					forced_height = 30,
				},
				left = 4,
				bottom = 4,
				layout = wibox.container.margin,
			})
			label_widget:connect_signal("button::release", cb)
			table.insert(theme_widgets, checkbox_widget)
			table.insert(theme_widgets, label_widget)
		end

		self.widget:reset()

		self.widget:setup({
			{
				{
					widget = wibox.widget.separator,
					orientation = "horizontal",
					forced_height = 40,
				},
				{
					{
						text = "Theme",
						widget = wibox.widget.textbox,
						forced_height = 40,
						font = "Terminus Bold 14",
					},
					left = 10,
					right = 10,
					layout = wibox.container.margin,
				},
				{
					widget = wibox.widget.separator,
					orientation = "horizontal",
					forced_height = 40,
				},
				expand = "outside",
				homogeneous = false,
				layout = wibox.layout.align.horizontal,
			},
			{
				homogeneous = false,
				layout = wibox.layout.grid.vertical,
				forced_num_cols = 2,
				forced_num_rows = #available_themes,
				table.unpack(theme_widgets),
			},
			homogeneous = false,
			expand = true,
			layout = wibox.layout.align.vertical,
		})
	end

	appearance_panel:update()

	return appearance_panel
end

return factory
