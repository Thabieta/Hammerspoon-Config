-- 切换为拼音
local function Pinyin()
	--hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
	hs.keycodes.setMethod("Pinyin - Simplified")
end
-- 切换为roma
local function Romaji()
	--hs.keycodes.currentSourceID("com.apple.inputmethod.Kotoeri.Roman")
	hs.keycodes.setMethod("Romaji")
end
-- 切换为日文
local function Japanese()
	--hs.keycodes.currentSourceID("com.apple.inputmethod.Kotoeri.Japanese")
	hs.keycodes.setMethod("Hiragana")
end
-- 切换为英文
local function English()
	local roma = false
	for key, value in pairs(hs.keycodes.methods()) do
		if value == "Romaji" then
			roma = true
		end	
	end
	if roma == true then
		--hs.keycodes.currentSourceID("com.apple.inputmethod.Kotoeri.Roman")
		hs.keycodes.setMethod("Romaji")
	else
		hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
	end
end
-- 切换输入法快捷键
hs.hotkey.bind(hyper, '/', Pinyin)
hs.hotkey.bind(hyper, ',', English)
hs.hotkey.bind(hyper, '.', Japanese)
--[[
-- 设置App对应的输入法
local app2Ime = {
	{'/System/Library/CoreServices/Finder.app', 'Pinyin'},
	{'/Applications/System Preferences.app', 'Pinyin'},
	{'/Applications/微信.app', 'Pinyin'},
	{'/Applications/Google Chrome.app', 'Pinyin'},
	{'/Applications/Preview.app', 'Pinyin'},
		}
function updateFocusAppInputMethod()
	local ime = 'English'
	local focusAppPath = hs.window.frontmostWindow():application():path()
	for index, app in pairs(app2Ime) do
		local appPath = app[1]
		local expectedIme = app[2]
		if focusAppPath == appPath then
			ime = expectedIme
			break
		end
	end
	if ime == 'English' then
		English()
	else
		Pinyin()
	end
end
-- 查看当前激活窗口的App路径及名称
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    hs.alert.show("App path:        "
    ..hs.window.focusedWindow():application():path()
    .."\n"
    .."App name:      "
    ..hs.window.focusedWindow():application():name()
    .."\n"
    .."IM source id:  "
    ..hs.keycodes.currentSourceID())
end)
-- 监视App启动或终止
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        updateFocusAppInputMethod()
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
--]]
