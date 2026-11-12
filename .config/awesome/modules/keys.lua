-- Global and client keybindings. Mod4 = Super / Windows key.
local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local mod = "Mod4"
local terminal = "alacritty"
local launcher = "rofi -show drun"
local M = {}

M.clientkeys = gears.table.join(
    awful.key({ mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ mod, "Shift" }, "w", function(c) c:kill() end,
        { description = "close window", group = "client" }),
    awful.key({ mod, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ mod }, "n", function(c) c.minimized = true end,
        { description = "minimize", group = "client" }),
    awful.key({ mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
        { description = "maximize", group = "client" })
)

M.clientbuttons = gears.table.join(
    awful.button({}, 1, function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }) end),
    awful.button({ mod }, 1, function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }); awful.mouse.client.move(c) end),
    awful.button({ mod }, 3, function(c) c:emit_signal("request::activate", "mouse_click", { raise = true }); awful.mouse.client.resize(c) end)
)

local globalkeys = gears.table.join(
    awful.key({ mod }, "Return", function() awful.spawn(terminal) end, { description = "terminal", group = "Nyxora" }),
    awful.key({ mod }, "e", function() awful.spawn.with_shell(launcher) end, { description = "application launcher", group = "Nyxora" }),
    awful.key({ mod }, "s", hotkeys_popup.show_help, { description = "show keybindings", group = "Nyxora" }),
    awful.key({ mod, "Control" }, "r", awesome.restart, { description = "restart Awesome", group = "Nyxora" }),
    awful.key({ mod, "Shift" }, "q", awesome.quit, { description = "quit Awesome", group = "Nyxora" }),
    awful.key({ mod, "Shift" }, "t", function() awful.spawn.with_shell("nyxora-theme dark") end, { description = "dark theme", group = "Appearance" }),
    awful.key({ mod, "Control" }, "t", function() awful.spawn.with_shell("nyxora-theme light") end, { description = "light theme", group = "Appearance" }),
    awful.key({ mod }, "j", function() awful.client.focus.byidx(1); if client.focus then client.focus:raise() end end, { description = "focus next window", group = "Windows" }),
    awful.key({ mod }, "k", function() awful.client.focus.byidx(-1); if client.focus then client.focus:raise() end end, { description = "focus previous window", group = "Windows" }),
    awful.key({ mod }, "space", function() awful.layout.inc(1) end, { description = "next layout", group = "Layout" }),
    awful.key({ mod, "Shift" }, "space", function() awful.layout.inc(-1) end, { description = "previous layout", group = "Layout" }),
    awful.key({ mod }, "h", function() awful.tag.incmwfact(-0.05) end, { description = "shrink master", group = "Layout" }),
    awful.key({ mod }, "l", function() awful.tag.incmwfact(0.05) end, { description = "grow master", group = "Layout" }),
    awful.key({ mod, "Control" }, "n", function() awful.screen.focus_relative(1) end, { description = "next screen", group = "Screen" }),
    awful.key({ mod, "Shift" }, "s", function()awful.spawn("flameshot gui")end, { description = "take screenshot", group = "Nyxora" }),
    awful.key({ mod }, "r", function() awful.spawn("rofi -show run") end, { description = "run command", group = "Nyxora" })
)

for i = 1, 5 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ mod }, "#" .. (i + 9), function() local s = awful.screen.focused(); local t = s.tags[i]; if t then t:view_only() end end,
            { description = "view workspace " .. i, group = "Workspace" }),
        awful.key({ mod, "Shift" }, "#" .. (i + 9), function() if client.focus then local t = client.focus.screen.tags[i]; if t then client.focus:move_to_tag(t) end end end,
            { description = "move window to workspace " .. i, group = "Workspace" }))
end

root.keys(globalkeys)
return M
