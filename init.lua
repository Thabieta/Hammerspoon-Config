-- Hammerspoon设置
hs.preferencesDarkMode = true
hotkey = require "hs.hotkey"
hyperkey = {"cmd", "shift", "ctrl"}
hotkey.bind(hyperkey, "R", hs.reload)
hotkey.bind(hyperkey, "p", hs.openPreferences)
hotkey.bind({"alt"}, "Z", hs.toggleConsole)
-- 组件加载管理
local module_list = {
	"module.IME",
	"module.Spotlightlike",
	"module.iTunes",
	"module.window",
		}
for _, v in pairs(module_list) do
	require (v)
end
-- Baby
local owner = hs.host.localizedName()
if owner ~= "鳳凰院カミのMacBook Pro" then
	require "module.autoupdate"
end
