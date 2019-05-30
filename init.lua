hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.preferencesDarkMode = true
-- 重新加载快捷键
hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
	hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end
-- 偏好设置快捷键
hsopenPreferences_keys = hsopenPreferences_keys or {{"cmd", "shift", "ctrl"}, "p"}
if string.len(hsopenPreferences_keys[2]) > 0 then
	hs.hotkey.bind(hsopenPreferences_keys[1], hsopenPreferences_keys[2], "Open Preferences", function() hs.openPreferences() end)
end
-- 控制台快捷键
hsconsole_keys = hsconsole_keys or {"alt", "Z"}
if string.len(hsconsole_keys[2]) > 0 then
	hs.hotkey.bind(hsconsole_keys[1], hsconsole_keys[2], "Toggle Hammerspoon Console", function() hs.toggleConsole() end)
end
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
