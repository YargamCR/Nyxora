-- Nyxora | Floating Vertical Dock

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local M = {}

local function rounded(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

local function make_workspace_button(tag)
    local label = wibox.widget {
        text = tag.name,
        align = "center",
        valign = "center",
        forced_width = 44,
        forced_height = 34,
        font = beautiful.font,
        widget = wibox.widget.textbox,
    }

    local background = wibox.widget {
        label,
        fg = beautiful.fg_normal,
        bg = beautiful.workspace_bg,
        shape = rounded(6),
        shape_border_width = 1,
        shape_border_color = beautiful.workspace_border,
        widget = wibox.container.background,
    }

    local button = wibox.widget {
        background,
        left = 3,
        right = 3,
        top = 4,
        bottom = 4,
        widget = wibox.container.margin,
    }

    local function update()
        local selected = tag.selected
        background:set_bg(
            selected and beautiful.accent or beautiful.workspace_bg
        )
        background:set_fg(
            selected and beautiful.bg_normal or beautiful.fg_normal
        )
    end

    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            tag:view_only()
        end),
        awful.button({}, 3, function()
            awful.tag.viewtoggle(tag)
        end)
    ))

    tag:connect_signal("property::selected", update)
    tag:connect_signal("property::name", function()
        label.text = tag.name
        update()
    end)

    update()
    return button
end

local function make_workspaces(s)
    local list = wibox.widget {
        spacing = 5,
        layout = wibox.layout.fixed.vertical,
    }

    for _, tag in ipairs(s.tags) do
        list:add(make_workspace_button(tag))
    end

    return list
end

function M.setup(s)
    local logo = wibox.widget {
        {
            image = gears.filesystem.get_configuration_dir() .. "assets/nyxora-emblem.png",
            resize = true,
            forced_width = 64,
            forced_height = 64,
            widget = wibox.widget.imagebox,
        },
        margins = 3,
        widget = wibox.container.margin,
    }

    local launch = wibox.widget {
        {
            {
                text = "⌕",
                align = "center",
                valign = "center",
                font = beautiful.icon_font,
                widget = wibox.widget.textbox,
            },
            fg = beautiful.fg_normal,
            bg = beautiful.bg_focus,
            shape = rounded(6),
            widget = wibox.container.background,
        },
        margins = 5,
        widget = wibox.container.margin,
    }

    launch:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.spawn.with_shell("rofi -show drun")
        end)
    ))

    local workspaces = make_workspaces(s)

    local clock = wibox.widget {
        format = "%H\n%M",
        align = "center",
        valign = "center",
        font = beautiful.clock_font,
        widget = wibox.widget.textclock,
    }

    local tray
    if s.index == 1 then
        tray = wibox.widget.systray()
        tray:set_base_size(14)
    else
        tray = wibox.widget.textbox("")
    end

    local geo = s.geometry
    local dock_height = math.min(620, geo.height - 48)

    s.nyxora_bar = wibox {
        screen = s,
        x = geo.x + 14,
        y = geo.y + math.floor((geo.height - dock_height) / 2),
        width = 72,
        height = dock_height,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        border_width = 1,
        border_color = beautiful.border,
        shape = rounded(12),
        ontop = true,
        visible = true,
        type = "dock",
    }

    s.nyxora_bar:setup {
        {
            {
                logo,
                launch,
                {
                    workspaces,
                    top = 10,
                    bottom = 10,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 8,
            },
            nil,
            {
                clock,
                {
                    tray,
                    margins = 5,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 8,
            },
            layout = wibox.layout.align.vertical,
        },
        left = 5,
        right = 5,
        top = 10,
        bottom = 10,
        widget = wibox.container.margin,
    }
end

return M
