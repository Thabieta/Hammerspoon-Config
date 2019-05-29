hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.preferencesDarkMode = true
hyper = {"ctrl", "alt"}
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
-- Spoon加载管理
if not hspoon_list then
	hspoon_list = {
		--"HSearch",
		--"WinWin",
		--"Seal",
		}
end
for _, v in pairs(hspoon_list) do
	hs.loadSpoon(v)
end
------------------------------------------------------------------------------------------
-- 输入法切换
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
------------------------------------------------------------------------------------------
-- 类Spotlight搜索
local search = nil
local base = {
		[1] = { name = "百度", baseurl = "https://www.baidu.com/s?wd=keyword", },
		[2] = { name = "Google", baseurl = "https://www.google.com/search?q=keyword", },
		[3] = { name = "ウィキペディア", baseurl = "https://ja.wikipedia.org/wiki/keyword", },
		[4] = { name = "Google翻訳", baseurl = "https://translate.google.com/#view=home&op=translate&sl=auto&tl=zh-CN&text=keyword", },
	}
-- 生成搜索列表
function searchList()
	local choices = {}
	local query = hs.http.encodeForQuery(search:query()):gsub("%%", "%%%%")
       	for key,data in ipairs(base) do
       			local full_url = data["baseurl"]:gsub ("keyword", query)
        		local choice = {}
        		choice["text"] = data["name"]
			--choice["subText"] = full_url
        		choice["fullurl"] = full_url
        		table.insert(choices, choice)
	end
	return choices
end
-- 执行的动作
function searchcompletionCallback(rowInfo)
	if rowInfo == nil or string.len(search:query()) == 0 then
        	return
	elseif string.find(search:query(), "://") ~= nil or string.find(search:query(), "www.") ~= nil or string.find(search:query(), ".com") ~= nil or string.find(search:query(), ".jp") ~= nil then
		hs.urlevent.openURLWithBundle(search:query(), "com.apple.Safari")
	else
		hs.urlevent.openURLWithBundle(rowInfo["fullurl"], "com.apple.Safari")
    	end
end
-- 搜索关键词改变时的行为
function queryChangedCallback()
	if queryChangedTimer then
		queryChangedTimer:stop()
	end
	queryChangedTimer = hs.timer.doAfter(0.2, function() 
			search:choices(searchList()) 
			search:refreshChoicesCallback()	end)
end
-- 输出Spotlight式输入框
function searchMain()
	search = hs.chooser.new(searchcompletionCallback)
	search:placeholderText("検索したいキーワードを入力")
	search:rows(4)
	search:queryChangedCallback(queryChangedCallback)
	if search:isVisible() then 
		search:hide()
	else 
		search:show()
	end
	return search
end
hs.hotkey.bind({"alt"}, 'space', "Toggle show chooser", searchMain)
------------------------------------------------------------------------------------------
-- iTunes菜单栏
local iTunesBar = nil
local songtitle = nil
local songloved = nil
local songdisliked = nil
local songrating = nil
local songalbum = nil
-- 删除Menubar
function deletemenubar()
	if iTunesBar ~= nil then
		iTunesBar:delete()
	end
end
-- 创建标题
function settitle()
	local track = hs.itunes.getCurrentTrack()
	local artist = hs.itunes.getCurrentArtist()
	local album = hs.itunes.getCurrentAlbum()
	local itunesinfo = '🎵' .. track .. ' - ' .. artist
	local infolength = string.len(itunesinfo)
	if infolength < 90 then
		iTunesBar:setTitle(itunesinfo)
	else
		iTunesBar:setTitle('🎵' .. track)
	end
end
-- 跳转至当前播放的歌曲
function locate()
	hs.osascript.applescript([[
		tell application "iTunes"
			activate
			tell application "System Events" to keystroke "l" using command down
		end tell
				]])
end
-- 保存本地曲目的专辑封面
function saveartwork()
	if hs.itunes.getCurrentAlbum() ~= songalbum then
		songalbum = hs.itunes.getCurrentAlbum()
		hs.osascript.applescript([[
			try
				tell application "iTunes"
					set theartwork to raw data of current track's artwork 1
					set theformat to format of current track's artwork 1
					if theformat is «class PNG » then
						set ext to ".png"
					else
						set ext to ".jpg"
					end if
				end tell
				set fileName to ("Macintosh HD:Users:hououinkami:.hammerspoon:" & "currentartwork" & ext)
				set outFile to open for access file fileName with write permission
				set eof outFile to 0
				write theartwork to outFile
				close access outFile
			end try
					]])
	end
end
-- 获取AppleMusic曲目的专辑封面
--local artworkurl = nil
function saveartworkam()
	local album = hs.itunes.getCurrentAlbum()
	local artist = hs.itunes.getCurrentArtist()
		local amurl = "https://itunes.apple.com/search?term=" .. hs.http.encodeForQuery(album .. " " .. artist) .. "&country=jp&entity=album&limit=1&output=json"
	--[[
	hs.http.asyncGet(amurl, nil, function(status, body, headers)
			if status == 200 then
				local songdata = hs.json.decode(body)
				artworkurl100 = songdata.results[1].artworkUrl100
			end
			artworkurl = artworkurl100:gsub("100x100", "1000x1000")
			local artworkfile = hs.image.imageFromURL(artworkurl):setSize({h = 300, w = 300}, absolute == true)
			artworkfile:saveToFile(hs.configdir .. "/currentartwork.jpg")
		end)
	--]]
		local status,body,headers = hs.http.get(amurl, nil)
		if status == 200 then
			local songdata = hs.json.decode(body)
			if songdata.resultCount ~= 0 then
				artworkurl100 = songdata.results[1].artworkUrl100
				artworkurl = artworkurl100:gsub("100x100", "1000x1000")
				local artworkfile = hs.image.imageFromURL(artworkurl):setSize({h = 300, w = 300}, absolute == true)
				artworkfile:saveToFile(hs.configdir .. "/currentartwork.jpg")
			end
		end
	return artworkurl
end
-- 创建菜单
function setmenu()
	local track = hs.itunes.getCurrentTrack()
	local artist = hs.itunes.getCurrentArtist()
	local album = hs.itunes.getCurrentAlbum()
	local _,loved,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's loved]])
	local _,disliked,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's disliked]])
	local _,rating,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's rating]])
	if loved == true then
		lovedtitle = "❤️ラブ済み"
	else
		lovedtitle = "🖤ラブ"
	end
	if disliked == true then
		dislikedtitle = "💔好きじゃない済み"
	else
		dislikedtitle = "🖤好きじゃない"
	end
	if rating == 100 then
		ratingtitle1 = hs.styledtext.new("⭑⭑⭑⭑⭑", {color = {hex = "#0000FF", alpha = 1}})
		ratingtitle2 = "⭑⭑⭑⭑⭐︎"
		ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		ratingtitle4 = "⭑⭑⭐︎⭐︎⭐︎"
		ratingtitle5 = "⭑⭐︎⭐︎⭐︎⭐︎"
		star5 = true
		star4 = false
		star3 = false
		star2 = false
		star1 = false
	elseif rating == 80 then
		ratingtitle1 = "⭑⭑⭑⭑⭑"
		ratingtitle2 = hs.styledtext.new("⭑⭑⭑⭑⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		ratingtitle4 = "⭑⭑⭐︎⭐︎⭐︎"
		ratingtitle5 = "⭑⭐︎⭐︎⭐︎⭐︎"
		star5 = false
		star4 = true
		star3 = false
		star2 = false
		star1 = false
	elseif rating == 60 then
		ratingtitle1 = "⭑⭑⭑⭑⭑"
		ratingtitle2 = "⭑⭑⭑⭑⭐︎"
		ratingtitle3 = hs.styledtext.new("⭑⭑⭑⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		ratingtitle4 = "⭑⭑⭐︎⭐︎⭐︎"
		ratingtitle5 = "⭑⭐︎⭐︎⭐︎⭐︎"
		star5 = false
		star4 = false
		star3 = true
		star2 = false
		star1 = false
	elseif rating == 40 then
		ratingtitle1 = "⭑⭑⭑⭑⭑"
		ratingtitle2 = "⭑⭑⭑⭑⭐︎"
		ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		ratingtitle4 = hs.styledtext.new("⭑⭑⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		ratingtitle5 = "⭑⭐︎⭐︎⭐︎⭐︎"
		star5 = false
		star4 = false
		star3 = false
		star2 = true
		star1 = false
	elseif rating == 20 then
		ratingtitle1 = "⭑⭑⭑⭑⭑"
		ratingtitle2 = "⭑⭑⭑⭑⭐︎"
		ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		ratingtitle4 = "⭑⭑⭐︎⭐︎⭐︎"
		ratingtitle5 = hs.styledtext.new("⭑⭐︎⭐︎⭐︎⭐︎", {color = {hex = "#0000FF", alpha = 1}})
		star5 = false
		star4 = false
		star3 = false
		star2 = false
		star1 = true
	elseif rating == 0 then
		ratingtitle1 = "⭑⭑⭑⭑⭑"
		ratingtitle2 = "⭑⭑⭑⭑⭐︎"
		ratingtitle3 = "⭑⭑⭑⭐︎⭐︎"
		ratingtitle4 = "⭑⭑⭐︎⭐︎⭐︎"
		ratingtitle5 = "⭑⭐︎⭐︎⭐︎⭐︎"
		star5 = false
		star4 = false
		star3 = false
		star2 = false
		star1 = false
	end
	saveartwork()
	-- 判断是否为Apple Music
	local _,kind,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's kind]])
	if string.len(kind) > 0 then
		-- 获取图片后缀名
		local _,format,_ = hs.osascript.applescript([[tell application "iTunes" to get format of current track's artwork 1 as string]])
		if string.find(format, "PNG") then
			ext = "png"
		else
			ext = "jpg"
		end
		local artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork." .. ext):setSize({h = 300, w = 300}, absolute == true)
		imagemenu = {title = "", image = artwork, fn = locate}
	else
		local artworkurl = saveartworkam()
		if artworkurl ~= nil then
			--local artwork = hs.image.imageFromURL(artworkurl)
			local artwork = hs.image.imageFromPath(hs.configdir .. "/currentartwork.jpg")
			imagemenu = {title = "", image = artwork, fn = locate}
		else
			imgaemenu = {}
		end
	end
	-- 显示菜单
	iTunesBar:setMenu({
			imagemenu,
			{title = "🎸" .. track, fn = locate},
			{title = "👩🏻‍🎤" .. artist, fn = locate},
			{title = "💿" .. album, fn = locate},
			{title = "-"},
			{title = lovedtitle, fn = function() hs.osascript.applescript([[
						tell application "iTunes"
							if current track's loved is false then
								set current track's loved to true
							else
								set current track's loved to false
							end if
						end tell
						]]) end},
			{title = dislikedtitle, fn = function() hs.osascript.applescript([[
						tell application "iTunes"
							if current track's disliked is false then
								set current track's disliked to true
							else
								set current track's disliked to false
							end if
						end tell
						]]) end},
			{title = ratingtitle1, checked = star5, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 100]]) end},
			{title = ratingtitle2, checked = star4, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 80]]) end},
			{title = ratingtitle3, checked = star3, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 60]]) end},
			{title = ratingtitle4, checked = star2, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 40]]) end},
			{title = ratingtitle5, checked = star1, fn = function() hs.osascript.applescript([[tell application "iTunes" to set current track's rating to 20]]) end},
			})
end
-- 延迟函数
function delay(gap, func)
	local delaytimer = hs.timer.delayed.new(gap, func)
	delaytimer:start() 
end
-- 更新Menubar
function updatemenubar()
	local track = hs.itunes.getCurrentTrack()
	local _,loved,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's loved]])
	local _,disliked,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's disliked]])
	local _,rating,_ = hs.osascript.applescript([[tell application "iTunes" to get current track's rating]])
	if track ~= songtitle or loved ~= songloved or disliked ~= songdisliked or rating ~= songrating then --若更换了曲目
		songtitle = track
		songloved = loved
		songdisliked = disliked
		songrating = rating
		settitle()
		delay(1, setmenu)
	end
end
-- 创建Menubar
function setitunesbar()
	if hs.itunes.isRunning() then -- 若iTunes正在运行
		-- 若首次播放则新建menubar item
		if iTunesBar == nil and hs.itunes.getCurrentTrack() ~= nil then
			iTunesBar = hs.menubar.new()
		end
		if hs.itunes.getCurrentTrack() ~= nil then
			updatemenubar()
		else -- 若iTunes停止播放
			deletemenubar()
		end
	else -- 若iTunes没有运行
		deletemenubar()
	end
	hs.timer.doAfter(1, setitunesbar)
end
setitunesbar()
------------------------------------------------------------------------------------------
-- 窗口管理
hs.window.animationDuration = 0
local winhistory = {}
local winhistory2 = {}
-- 记录窗口历史
local function windowStash(window)
	local winid = window:id()
	local winf = window:frame()
	-- 确认存储历史不超过50个
	if #winhistory > 50 then
		-- 移除最后一次历史
		table.remove(winhistory)
	end
	local winstru = {winid, winf}
	table.insert(winhistory, winstru)
end
-- 记录窗口初始位置
local function windowStash2(window)
	local winid = window:id()
	local winf = window:frame()
	if #winhistory2 > 50 then
		table.remove(winhistory2)
	end
	local winstru = {winid, winf}
	local exist = false
	for idx,val in ipairs(winhistory2) do
		if val[1] == winid then
			exist = true
		end
	end
	if exist == false then
		table.insert(winhistory2, winstru) 
	end
end
-- 窗口动作
function Resize(option)
	local cwin = hs.window.focusedWindow()
	if cwin then
		local cscreen = cwin:screen()
		local cres = cscreen:fullFrame()
		local wf = cwin:frame()
		if option == "halfleft" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfright" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x+cres.w/2, y=cres.y, w=cres.w/2, h=cres.h})
		elseif option == "halfup" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h/2})
		elseif option == "halfdown" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y+cres.h/2, w=cres.w, h=cres.h/2})
		elseif option == "fullscreen" then
			windowStash2(cwin)
			cwin:setFrame({x=cres.x, y=cres.y, w=cres.w, h=cres.h})
		elseif option == "center" then
			windowStash2(cwin)
			cwin:centerOnScreen()
		elseif option == "expand" then
			cwin:setFrame({x=wf.x-stepw, y=wf.y-steph, w=wf.w+(stepw*2), h=wf.h+(steph*2)})
		elseif option == "shrink" then
			cwin:setFrame({x=wf.x+stepw, y=wf.y+steph, w=wf.w-(stepw*2), h=wf.h-(steph*2)})
		else
			hs.alert.show("Unknown option: " .. option)
		end
	else
		hs.alert.show("ウィンドウは指定されていません！")
	end
end
-- 撤销最近一次动作
function Undo()
	local cwin = hs.window.focusedWindow()
	local cwinid = cwin:id()
	for idx,val in ipairs(winhistory) do
        -- Has this window been stored previously?
		if val[1] == cwinid then
			cwin:setFrame(val[2])
		end
	end
end
-- 重置回初始状态
function Reset()
	local cwin = hs.window.focusedWindow()
	local cwinid = cwin:id()
	for idx,val in ipairs(winhistory2) do
		if val[1] == cwinid then
			cwin:setFrame(val[2])
		end
	end
end
hs.hotkey.bind(hyper, 'right', function() Resize("halfright") end)
hs.hotkey.bind(hyper, 'left', function() Resize("halfleft") end) 
hs.hotkey.bind(hyper, 'up', function() Resize("halfup") end)
hs.hotkey.bind(hyper, 'down', function() Resize("halfdown") end)
hs.hotkey.bind(hyper, 'c', function() Resize("center") end)
hs.hotkey.bind(hyper, 'return', function() Resize("fullscreen") end)
hs.hotkey.bind(hyper, 'delete', function() Reset() end)
------------------------------------------------------------------------------------------
