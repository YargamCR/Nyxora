-- Client behavior and appearance.
local awful = require("awful")
local beautiful = require("beautiful")

awful.rules.rules = {
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = require("modules.keys").clientkeys,
            buttons = require("modules.keys").clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_offscreen + awful.placement.no_overlap
        },
    },
    { rule = { class = "Pavucontrol" }, properties = { floating = true, ontop = true } },
    { rule = { class = "Nm-connection-editor" }, properties = { floating = true, ontop = true } },
}
