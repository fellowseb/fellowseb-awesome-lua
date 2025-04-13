local capi = {
	screen = screen,
	client = client,
}
local awful = require("awful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local beautiful = require("beautiful")
local appearance_panel = require("fellowseb.widget.appearance_panel")
local menu_item = require("fellowseb.widget.menu_item")
local sicon = require("fellowseb.service.icon")

local dpi = beautiful.xresources.apply_dpi

local function get_screen(s)
	return s and capi.screen[s]
end

local widget = {}

--- @param deps { theme_service: theme_service, awesome: awesome }
function widget.new(deps, args)
	local theme_service = deps.theme_service
	local awesome = deps.awesome
	args = args or {}
	local widget_instance = {
		_cached_wiboxes = {},
		_widget_settings_loaded = false,
	}

	function widget_instance:_load_widget_settings()
		if self._widget_settings_loaded then
			return
		end
		self.width = args.width or dpi(800)
		self.height = args.height or dpi(600)
		self.bg = beautiful.titlebar_bg_normal
		self.fg = args.fg or beautiful.hotkeys_fg or beautiful.fg_normal
		self.border_width = args.border_width or beautiful.hotkeys_border_width or beautiful.border_width
		self.border_color = beautiful.fg_normal
		self.shape = args.shape or gshape.rounded_rect
		self.opacity = args.opacity or beautiful.hotkeys_opacity or 1
		self.font = args.font or beautiful.hotkeys_font or "Monospace Bold 9"
		self._widget_settings_loaded = true
	end

	function widget_instance:_create_wibox(s)
		s = get_screen(s)
		local wa = s.workarea
		local height = (self.height < wa.height) and self.height or (wa.height - self.border_width * 2)
		local width = (self.width < wa.width) and self.width or (wa.width - self.border_width * 2)

		local mywibox = wibox({
			ontop = true,
			bg = self.bg,
			fg = self.fg,
			opacity = 1,
			border_width = 2,
			border_color = self.border_color,
			shape = self.shape,
			type = "dialog",
		})
		local widget_obj = {
			wibox = mywibox,
			active_page = nil,
		}
		mywibox:geometry({
			x = wa.x + math.floor((wa.width - width - self.border_width * 2) / 2),
			y = wa.y + math.floor((wa.height - height - self.border_width * 2) / 2),
			width = width,
			height = height,
		})

		widget_obj.get_page_panel = function()
			if widget_obj.active_page == "appearence" then
				return appearance_panel({
					theme_service = theme_service,
					awesome = awesome,
				}).widget
			end
			if widget_obj.active_page == "updates" then
				return wibox.widget.textbox("Updates panel")
			end
			return wibox.widget.textbox("No panel")
		end

		widget_obj.update = function()
			mywibox:set_widget(wibox.widget({
				{
					{
						{
							text = "System Settings",
							align = "center",
							valign = "center",
							widget = wibox.widget.textbox,
							font = "Terminus Bold 20",
							forced_height = dpi(40),
						},
						{
							{
								{
									{
										menu_item.create({
											label = "Information",
											icon = wibox.widget.imagebox(
												sicon.svg_surf(
													"/home/seb/.config/awesome/icons/info-square.svg",
													"#DDDDDD"
												)
											),
											state = widget_obj.active_page == "information" and "active" or "inactive",
											on_click = function()
												widget_obj.active_page = "information"
												widget_obj.update()
											end,
										}).widget,
										menu_item.create({
											label = "Appearence",
											icon = wibox.widget.imagebox(
												sicon.svg_surf(
													"/home/seb/.config/awesome/icons/roller-brush.svg",
													"#DDDDDD"
												)
											),
											state = widget_obj.active_page == "appearence" and "active" or "inactive",
											on_click = function()
												widget_obj.active_page = "appearence"
												widget_obj.update()
											end,
										}).widget,
										menu_item.create({
											label = "Updates",
											icon = wibox.widget.imagebox(
												sicon.svg_surf(
													"/home/seb/.config/awesome/icons/refresh-cw-04.svg",
													"#DDDDDD"
												)
											),
											state = widget_obj.active_page == "updates" and "active" or "inactive",
											on_click = function()
												widget_obj.active_page = "updates"
												widget_obj.update()
											end,
										}).widget,
										menu_item.create({
											label = "Network",
											icon = wibox.widget.imagebox(
												sicon.svg_surf("/home/seb/.config/awesome/icons/wifi.svg", "#DDDDDD")
											),
											state = widget_obj.active_page == "network" and "active" or "inactive",
											on_click = function()
												widget_obj.active_page = "network"
												widget_obj.update()
											end,
										}).widget,
										menu_item.create({
											label = "Backups",
											icon = wibox.widget.imagebox(
												sicon.svg_surf(
													"/home/seb/.config/awesome/icons/upload-cloud-01.svg",
													"#DDDDDD"
												)
											),
											state = widget_obj.active_page == "backups" and "active" or "inactive",
											on_click = function()
												widget_obj.active_page = "backups"
												widget_obj.update()
											end,
										}).widget,
										forced_width = dpi(200),
										homogeneous = true,
										layout = wibox.layout.fixed.vertical,
									},
									bg = beautiful.bg_focus,
									widget = wibox.container.background,
								},
								layout = wibox.container.margin,
								left = 4,
								right = 4,
								top = 4,
								bottom = 4,
							},
							{
								widget_obj.get_page_panel(),
								layout = wibox.container.margin,
								left = 20,
								right = 20,
								top = 20,
								bottom = 20,
							},
							-- expand = "inside",
							homogeneous = false,
							layout = wibox.layout.fixed.horizontal,
						},
						expand = "inside",
						homogeneous = false,
						layout = wibox.layout.align.vertical,
					},
					layout = wibox.container.margin,
					left = 20,
					right = 20,
					top = 20,
					bottom = 20,
				},
				bg = self.bg,
				widget = wibox.container.background,
			}))
		end

		function widget_obj.toggle(_self)
			if _self.wibox.visible then
				_self.hide(_self)
			else
				_self.show(_self)
			end
		end
		function widget_obj.show(_self)
			_self.wibox.visible = true
		end
		function widget_obj.hide(_self)
			_self.wibox.visible = false
			if _self.keygrabber then
				awful.keygrabber.stop(_self.keygrabber)
			end
		end

		widget_obj.update()

		return widget_obj
	end

	--- Show settings panel.
	-- @tparam[opt] screen s Screen.
	function widget_instance:toggle_panel(s)
		self:_load_widget_settings()

		s = s or (awful.screen.focused())

		if not self._cached_wiboxes[s] then
			self._cached_wiboxes[s] = self:_create_wibox(s)
		end
		local help_wibox = self._cached_wiboxes[s]

		help_wibox:toggle()

		-- help_wibox.keygrabber = awful.keygrabber.run(function(_, _key, _event) end)
		-- return help_wibox.keygrabber
	end

	return widget_instance
end

local function get_default_widget(deps, args)
	if not widget.default_widget then
		widget.default_widget = widget.new(deps, args)
	end
	return widget.default_widget
end

function widget.show(deps, args, ...)
	return get_default_widget(deps, args):show_panel(...)
end

function widget.toggle(deps, args, ...)
	return get_default_widget(deps, args):toggle_panel(...)
end

return widget

-- vim: filetype=lua:expandtab:shiftwidth=2:tabstop=4:softtabstop=4:textwidth=80
