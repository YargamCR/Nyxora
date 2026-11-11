-- Minimal vertical bar: workspaces, launcher, clock and tray.
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local M = {}

local function taglist(screen)
    return awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({}, 1, function(tag) tag:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle)
        ),
        layout = { spacing = 7, layout = wibox.layout.fixed.vertical },
        widget_template = {
            {
                { id = "text", widget = wibox.widget.textbox, align = "center" },
                margins = { left = 9, right = 9, top = 7, bottom = 7 },
                widget = wibox.container.margin,
            },
            id = "background", widget = wibox.container.background,
            shape = gears.shape.rounded_rect,
            create_callback = function(self, tag)
                self:get_children_by_id("text")[1].text = tag.name
                self.bg = tag.selected and beautiful.tag_bg_selected or beautiful.tag_bg
                self.fg = tag.selected and beautiful.accent or beautiful.fg_normal
            end,
            update_callback = function(self, tag)
                self:get_children_by_id("text")[1].text = tag.name
                self.bg = tag.selected and beautiful.tag_bg_selected or beautiful.tag_bg
                self.fg = tag.selected and beautiful.accent or beautiful.fg_normal
            end,
        },
    }
end

function M.setup(s)
    local clock = wibox.widget {
        format = "%H\n%M", align = "center", valign = "center",
        font = beautiful.clock_font, widget = wibox.widget.textclock,
    }
    local logo = wibox.widget {
        { text = "n", align = "center", valign = "center", font = beautiful.logo_font, widget = wibox.widget.textbox },
        fg = beautiful.bg_normal, bg = beautiful.accent,
        shape = gears.shape.rounded_rect, widget = wibox.container.background,
    }
    local launch = wibox.widget {
        { text = "⌕", align = "center", valign = "center", font = beautiful.icon_font, widget = wibox.widget.textbox },
        fg = beautiful.fg_normal, widget = wibox.container.background,
    }
    launch:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn.with_shell("rofi -show drun") end)))
    local tray
    if s.index == 1 then
        tray = wibox.widget.systray()
        tray:set_base_size(14)
    else
        tray = wibox.widget.textbox("")
    end

    s.nyxora_bar = awful.wibar {
        screen = s, position = "left", width = beautiful.bar_width,
        bg = beautiful.wibar_bg, fg = beautiful.wibar_fg,
        ontop = true, visible = true,
    }
    s.nyxora_bar:setup {
        {
            { logo, margins = 9, widget = wibox.container.margin },
            launch,
            { taglist(s), margins = { top = 12, bottom = 12 }, widget = wibox.container.margin },
            layout = wibox.layout.fixed.vertical, spacing = 12,
        },
        nil,
        {
            clock,
            { tray, margins = 8, widget = wibox.container.margin },
            layout = wibox.layout.fixed.vertical, spacing = 12,
        },
        layout = wibox.layout.align.vertical,
    }
end
return M
