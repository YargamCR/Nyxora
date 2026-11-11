-- Nyxora | AwesomeWM entry point
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
require("awful.autofocus")

local config_dir = gears.filesystem.get_configuration_dir()
local theme_file = config_dir .. "theme.lua"
if not gears.filesystem.file_readable(theme_file) then
    theme_file = config_dir .. "themes/dark.lua"
end
beautiful.init(theme_file)

require("core.errors")
require("core.rules")
require("core.signals")
require("modules.layouts")
require("modules.keys")

naughty.config.defaults.timeout = 4
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 14
naughty.config.defaults.spacing = 8

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
    require("widgets.bar").setup(s)
end)

-- Start optional desktop services once per session.
local function run_once(command, process)
    awful.spawn.with_shell(string.format("pgrep -u $USER -x %q >/dev/null || (%s)", process, command))
end
awful.spawn.with_shell(
    "if command -v nm-applet >/dev/null 2>&1; then " ..
    "pgrep -u \"$USER\" -x nm-applet >/dev/null || nm-applet; fi"
)

naughty.notify({
    title = "Nyxora",
    text = "Minimal desktop ready.",
    timeout = 3,
})
